
//
//  ViewController.swift
//  Sample1
//
//  Created by Development on 17/10/17.
//  Copyright © 2017 Development. All rights reserved.
//

import UIKit
import SnapKit

public typealias DashboardWidgetUIViewController = DashboardWidget & UIViewController

open class DashboardController: UIViewController {
    
    public var enablePullToRefresh: Bool = true
    public var lastRowTakesRemainingHeight: Bool = false
    
    public var scrollView: UIScrollView = {
        $0.alwaysBounceVertical = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        return $0
    }(UIScrollView(frame: CGRect.zero))
    
    public var widgets: [DashboardWidgetUIViewController] = []
    public var addWidgets: [DashboardWidgetUIViewController] = []
    
    public var refreshControl:UIRefreshControl = UIRefreshControl()
    
    var dispatchGroup: DispatchGroup = DispatchGroup()
    
    open override func loadView() {
        super.loadView()
        
        self.view = UIView(frame: CGRect.zero)
        self.view.backgroundColor = .white
        self.scrollView.backgroundColor = .clear

        self.scrollView.sizeToFit()
        
        self.view.addSubview(self.scrollView)
        
        self.view.contentMode = .redraw
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if self.enablePullToRefresh {
            self.refreshControl.addTarget(self, action: #selector(DashboardController.pullToRefresh(sender:)), for: .valueChanged)
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
            self.scrollView.addSubview(self.refreshControl)
        }
        
        self.addWidgetsToContainer()
        self.generateChildrenConstraints()
    }
    
    fileprivate func generateChildrenConstraints() {
        self.scrollView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.childViewControllers.enumerated().makeIterator().forEach { (index, childVC) in
            
            childVC.view.snp.makeConstraints({ make in
                
                make.left.width.equalToSuperview()
                
                switch index {
                case 0:
                    make.top.equalToSuperview()
                    if self.childViewControllers.count == 1 {
                        make.bottom.equalToSuperview()
                    }
                    
                case childViewControllers.count - 1:
                    make.top.equalTo(self.childViewControllers[index - 1].view.snp.bottom)
                    make.bottom.equalToSuperview()
                    
                default:
                    make.top.equalTo(self.childViewControllers[index - 1].view.snp.bottom)
                    
                }
                
            })
            
        }
        
    }
    
    @objc open func pullToRefresh(sender: UIRefreshControl) {
        self.addWidgets.forEach { widget in
            dispatchGroup.enter()
            widget.update()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if self.enablePullToRefresh && self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }

            self.setupWidgetsAndConstraints()
        }

    }
    
    public func reload(_ widget: DashboardWidget) {
        dispatchGroup.leave()
    }
    
    public func setupWidgetsAndConstraints() {
        self.removeWidgetsFromContainer()
        self.addWidgetsToContainer()
        
        self.widgets.forEach({ widget in
            widget.recreateConstraints()
        })
        
        self.generateChildrenConstraints()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    fileprivate func removeWidgetsFromContainer() {
        self.widgets.forEach { widget in
            widget.view.removeFromSuperview()
            widget.removeFromParentViewController()
        }
        self.addWidgets = []
    }
    
    fileprivate func addWidgetsToContainer() {
        self.widgets.forEach { widget in
            if widget.shouldInclude() {
                self.addWidgets.append(widget)
                self.addChildViewController(widget)
                self.scrollView.addSubview(widget.view)
                widget.didMove(toParentViewController: self)
            }
        }
    }
    
}
