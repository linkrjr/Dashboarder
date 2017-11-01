
//
//  ViewController.swift
//  Sample1
//
//  Created by Development on 17/10/17.
//  Copyright © 2017 Development. All rights reserved.
//

import UIKit

public typealias DashboardWidgetViewController = UIViewController & DashboardWidget

extension Array where Element == Bool {
    
    func all(are expected: Bool) -> Bool {
        return self.all { $0 == expected }
    }
    
    func any(is expected: Bool) -> Bool {
        return self.any { $0 == expected }
    }
    
}

extension Array {
    
    func all(passes condition: (Element) -> Bool) -> Bool {
        return self.filter { condition($0) }.count == self.count
    }
    
    func any(pass condition: (Element) -> Bool) -> Bool {
        return self.filter { condition($0) }.count > 0
    }
    
}

open class DashboardController: UIViewController {
    
    private var widgetsStatus: [UIViewController : DashboardWidgetStatus] = [:]
    
    public var enablePullToRefresh: Bool = true
    public var lastRowTakesRemainingHeight: Bool = false
    
    public var scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
    
    public var viewControllers: [DashboardWidgetViewController] = [] {
        didSet {
            self.widgetsStatus[viewControllers.last!] = .ready
            dump(self.widgetsStatus)
        }
    }
    
    public var refreshControl:UIRefreshControl = UIRefreshControl()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = self.calculateScrollViewFrame()
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        
        if self.enablePullToRefresh {
            self.refreshControl.addTarget(self, action: #selector(DashboardController.pullToRefresh(sender:)), for: .valueChanged)
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
            self.scrollView.addSubview(self.refreshControl)
        }
        
        self.calculateWidgetsFrame()
        self.scrollView.contentSize = self.calculateContentSize()
        
        self.viewControllers.forEach { widget in
            self.addChildViewController(widget)
            self.scrollView.addSubview(widget.view)
            widget.didMove(toParentViewController: self)
        }
        
    }
    
    @objc open func pullToRefresh(sender: UIRefreshControl) {
        self.viewControllers.forEach { widget in
            self.widgetsStatus[widget] = .updating
            widget.update()
        }
    }
    
    public func reload(_ widget: DashboardWidgetViewController) {
        self.widgetsStatus[widget] = .ready
        
        if !self.widgetsStatus.values.makeIterator().contains(.updating) {
            
            if self.enablePullToRefresh && self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.calculateWidgetsFrame()
            self.scrollView.contentSize = self.calculateContentSize()
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
        }
    }
    
    private func calculateWidgetsFrame() {
        var y: CGFloat = 0
        
        for (index, widget) in self.viewControllers.enumerated() {
            var height = widget.height()
            
            if self.lastRowTakesRemainingHeight
                && (index + 1) == self.viewControllers.count
                && height < (self.scrollView.bounds.height - y) {
                height = self.scrollView.bounds.height - y
            }
            
            widget.view.frame = CGRect(x: self.view.bounds.minX, y: y, width: self.view.bounds.maxX, height: height)
            y += height
        }
        
    }

    private func calculateContentSize() -> CGSize {
        let height: CGFloat = self.viewControllers.reduce(0) { (sum, widget) -> CGFloat in
            return sum + widget.height()
        }
        
        return CGSize(width: self.view.bounds.width, height: height)
    }
    
    fileprivate func calculateScrollViewFrame() -> CGRect {
        var height = self.view.bounds.height - UIApplication.shared.statusBarFrame.height
        if let navigationController = self.navigationController {
            height -= navigationController.navigationBar.frame.height
        }
        if let tabBarController = self.tabBarController {
            height -= tabBarController.tabBar.frame.height
        }
        return CGRect(origin: self.view.bounds.origin, size: CGSize(width: self.view.bounds.width, height: height))
    }

}
