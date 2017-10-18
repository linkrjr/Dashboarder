//
//  Widget.swift
//  Dashboarder
//
//  Created by Ronaldo Gomes on 17/10/17.
//

import Foundation

enum DashboardWidgetStatus {
    case ready
    case updating
}

public protocol DashboardWidget {
    func height() -> CGFloat
    func update()
}

public extension DashboardWidget where Self: UIViewController {
    
    var dashboardController: DashboardController? {
        guard let vc = self.parent as? DashboardController else { return nil }
        return vc
    }
    
}
