
//
//  ViewController.swift
//  Sample1
//
//  Created by Development on 17/10/17.
//  Copyright © 2017 Development. All rights reserved.
//

import UIKit
import SnapKit

open class DashboardController: UIViewController {
    
    fileprivate var includedWidgets: [UIViewController : DashboardWidgetStatus] = [:]
    
    public var enablePullToRefresh: Bool = true
    public var lastRowTakesRemainingHeight: Bool = false
    
    public var scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
    
    public var widgets: [DashboardWidget] = []
    
    public var refreshControl:UIRefreshControl = UIRefreshControl()
    
    open override func loadView() {
        super.loadView()
        
        self.view = UIView(frame: CGRect.zero)
        self.view.backgroundColor = .white
        self.scrollView = UIScrollView(frame: CGRect.zero)
        self.scrollView.backgroundColor = .clear
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false

        self.scrollView.sizeToFit()
        self.view.addSubview(self.scrollView)
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
        let childViewControllers: [UIViewController] = self.widgets.map { widget -> UIViewController in
            return widget as! UIViewController
        }
        
        childViewControllers.enumerated().forEach { (index, childVC) in
            
            childVC.view.snp.makeConstraints({ make in
                
                make.left.equalTo(0)
                make.width.equalToSuperview()
                
                switch index {
                case 0:
                    make.top.equalTo(0)
                case childViewControllers.count - 1:
                    make.top.equalTo(childViewControllers[index - 1].view.snp.bottom)
                    make.bottom.equalTo(0)
                default:
                    make.top.equalTo(childViewControllers[index - 1].view.snp.bottom)
                }
                
            })
            
        }
        
    }
    
    @objc open func pullToRefresh(sender: UIRefreshControl) {
        self.widgets.forEach { widget in
            if let vc = widget as? UIViewController {
                self.includedWidgets[vc] = .updating
                widget.update()
            }
        }
    }
    
    public func reload(_ widget: DashboardWidget) {
        if let vc = widget as? UIViewController {
            self.includedWidgets[vc] = .ready
        }
        
        if !self.includedWidgets.values.makeIterator().contains(.updating) {
            
            if self.enablePullToRefresh && self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }

            self.widgets.forEach({ widget in
                widget.recreateConstraints()
            })

            self.removeWidgetsFromContainer()
            self.addWidgetsToContainer()
            self.generateChildrenConstraints()
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
        }
    }
    
    fileprivate func removeWidgetsFromContainer() {
        self.widgets.forEach { widget in
            guard let vc = widget as? UIViewController else { return }
            self.includedWidgets[vc] = .ready
            vc.view.removeFromSuperview()
        }
    }
    
    fileprivate func addWidgetsToContainer() {
        self.widgets.forEach { widget in
            guard let vc = widget as? UIViewController else { return }
            self.includedWidgets[vc] = .ready
            self.addChildViewController(vc)
            self.scrollView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
}
