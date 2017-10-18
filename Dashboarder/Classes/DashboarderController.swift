
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
    
    @objc open dynamic var enablePullToRefresh: Bool = true
    
    var scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
    
    public var viewControllers: [DashboardWidgetViewController] = [] {
        didSet {
            self.widgetsStatus[viewControllers.last!] = .ready
            dump(self.widgetsStatus)
        }
    }
    
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        self.resizeContentSize()
        
        if self.enablePullToRefresh {
            self.refreshControl.addTarget(self, action: #selector(DashboardController.pullToRefresh(sender:)), for: .valueChanged)
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
            self.scrollView.addSubview(self.refreshControl)
        }
        
        self.self.calculateWidgetsFrame()
        
        self.viewControllers.forEach { widget in
            self.addChildViewController(widget)
            self.scrollView.addSubview(widget.view)
            widget.didMove(toParentViewController: self)
        }
        
    }
    
    @objc func pullToRefresh(sender: UIRefreshControl) {
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
            self.resizeContentSize()
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
        }
    }
    
    private func resizeContentSize() {
        let size = calculateContentSize()
        if self.view.bounds.contains(CGRect(origin: CGPoint(x: 0, y: 0) , size: size)) {
            self.scrollView.contentSize = self.view.bounds.size
        } else {
            self.scrollView.contentSize = size
        }
    }
    
    private func calculateWidgetsFrame() {
        var y: CGFloat = 0
        self.viewControllers.forEach { widget in
            widget.view.frame = CGRect(x: self.scrollView.bounds.minX, y: y, width: self.scrollView.bounds.maxX, height: widget.height())
            y += widget.height()
        }
    }
    
    private func calculateContentSize() -> CGSize {
        let height: CGFloat = self.viewControllers.reduce(0) { (sum, widget) -> CGFloat in
            return sum + widget.height()
        }
        return CGSize(width: self.view.bounds.width, height: height)
    }
    
}
