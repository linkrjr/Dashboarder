//
//  Widget.swift
//  Dashboarder
//
//  Created by Ronaldo Gomes on 17/10/17.
//

import Foundation

public protocol DashboardWidget {
    func update()
    func recreateConstraints()
    func shouldInclude() -> Bool
}

public extension DashboardWidget where Self: UIViewController {
    
    var dashboardController: DashboardController? {
        guard let vc = self.parent as? DashboardController else { return nil }
        return vc
    }
    
}
