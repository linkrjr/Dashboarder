//
//  Widget.swift
//  Dashboarder
//
//  Created by Ronaldo Gomes on 17/10/17.
//

import Foundation

public protocol DashboardWidget {
    // Return ZERO if widget is to be hidden
    func height() -> CGFloat
    func update()
}

public extension DashboardWidget where Self: UIViewController {
    
    var dashboardController: DashboardController? {
        guard let vc = self.parent as? DashboardController else { return nil }
        return vc
    }
    
}
