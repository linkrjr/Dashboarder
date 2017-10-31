
//
//  ViewController.swift
//  Sample1
//
//  Created by Development on 17/10/17.
//  Copyright © 2017 Development. All rights reserved.
//

import UIKit

open class DashboardController: UIViewController {
    
    public var enablePullToRefresh: Bool = true
    public var lastRowTakesRemainingHeight: Bool = false
    
    public var scrollView: UIScrollView = {
        $0.alwaysBounceVertical = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        return $0
    }(UIScrollView(frame: CGRect.zero))
    
    public var widgets: [DashboardWidget] = []
    
    public var refreshControl:UIRefreshControl = UIRefreshControl()
    
    var dispatchGroup: DispatchGroup = DispatchGroup()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = self.view.bounds
        self.view.addSubview(self.scrollView)
        
        if self.enablePullToRefresh {
            self.refreshControl.addTarget(self, action: #selector(DashboardController.pullToRefresh(sender:)), for: .valueChanged)
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
            self.scrollView.addSubview(self.refreshControl)
        }
        
        self.addWidgetsToContainer()
        self.calculateWidgetsFrame()
        self.scrollView.contentSize = self.calculateContentSize()
    
    }
    
    @objc open func pullToRefresh(sender: UIRefreshControl) {
        self.widgets.forEach { widget in
            dispatchGroup.enter()
            widget.update()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if self.enablePullToRefresh && self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.calculateWidgetsFrame()
            self.scrollView.contentSize = self.calculateContentSize()
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }

    }
    
    public func reload(_ widget: DashboardWidget) {
        dispatchGroup.leave()
    }
    
    fileprivate func addWidgetsToContainer() {
        self.widgets.forEach { widget in
            guard let vc = widget as? UIViewController else { return }
            self.addChildViewController(vc)
            self.scrollView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func calculateWidgetsFrame() {
        var y: CGFloat = 0
        
        self.widgets.forEach { widget in
            guard let vc = widget as? UIViewController else { return }
            vc.view.isHidden = widget.height() == 0
            vc.view.frame = CGRect(x: self.view.bounds.minX, y: y, width: self.view.bounds.maxX, height: widget.height())
            y += widget.height()
        }
    }

    fileprivate func calculateContentSize() -> CGSize {
        let height: CGFloat = self.widgets.reduce(0) { $0 + $1.height() }
        return CGSize(width: self.view.bounds.width, height: height)
    }

}
