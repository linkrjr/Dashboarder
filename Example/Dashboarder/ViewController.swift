//
//  ViewController.swift
//  Dashboarder
//
//  Created by Ronaldo Gomes on 10/17/2017.
//  Copyright (c) 2017 Ronaldo Gomes. All rights reserved.
//

import UIKit
import Dashboarder
import SnapKit

class ViewController: DashboardController, UIScrollViewDelegate {
    
    let widgets: [DashboardWidget] = [Widget(color: .red, height: 50), Widget(color: .blue,height: 50), AppCardsWidget(color: .yellow, height: 50)]
    
    let backgroundView = UIView(frame: CGRect.zero)
    let bottomView = UIView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        self.scrollView.delegate = self
        
        self.backgroundView.frame = CGRect(origin: self.scrollView.frame.origin, size: self.scrollView.contentSize)
        self.backgroundView.backgroundColor = .red
        self.scrollView.addSubview(self.backgroundView)
        
        self.widgets.forEach { self.viewControllers.append($0) }
        
        super.viewDidLoad()
    }
    
}

class Widget: UIViewController, DashboardWidget, ViewPort {
    
    private var defaultHeight: CGFloat!
    private var color: UIColor!
    
    var adapter: Adapter!
    
    func setup() {
        self.adapter = Adapter(viewPort: self)
    }
    
    required init(color: UIColor = .clear, height: CGFloat = 0) {
        super.init(nibName: nil, bundle: nil)
        self.color = color
        self.defaultHeight = height
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Ok", for: .normal)
        button.addTarget(self, action: #selector(Widget.didTapButton), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        self.view.backgroundColor = self.color
    }
    
    @objc func didTapButton() {
        let vc = NextViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func height() -> CGFloat {
        return self.defaultHeight
    }
    
    func update() {
        self.adapter.update(self)
    }
    
    func didFinishUpdating() {
        self.defaultHeight = self.defaultHeight * CGFloat(arc4random_uniform(UInt32(self.dashboardController!.viewControllers.count)) + 1)
        self.dashboardController?.reload(self)
    }
    
}

class AppCardsWidget: UIViewController, DashboardWidget, ViewPort {
    
    private var defaultHeight: CGFloat!
    private var color: UIColor!
    
    var adapter: Adapter!
    
    func setup() {
        self.adapter = Adapter(viewPort: self)
    }
    
    required init(color: UIColor = .clear, height: CGFloat = 0) {
        super.init(nibName: nil, bundle: nil)
        self.color = color
        self.defaultHeight = height
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Ok", for: .normal)
        button.addTarget(self, action: #selector(AppCardsWidget.didTapButton), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        self.view.backgroundColor = self.color
    }
    
    @objc func didTapButton() {
        let vc = NextViewController()
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(AppCardsWidget.didTapCancelButton))
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func height() -> CGFloat {
        return self.defaultHeight
    }
    
    func update() {
        self.adapter.update(self)
    }
    
    func didFinishUpdating() {
        self.defaultHeight = self.defaultHeight * CGFloat(arc4random_uniform(UInt32(self.dashboardController!.viewControllers.count)) + 1)
        self.dashboardController?.reload(self)
    }
    
}
