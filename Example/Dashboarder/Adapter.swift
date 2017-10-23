//
//  Adapter.swift
//  Dashboarder_Example
//
//  Created by Ronaldo Gomes on 18/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Dashboarder

protocol ViewPort {
    func didFinishUpdating()
}

class Adapter {
    
    var viewPort: ViewPort!
    
    init(viewPort: ViewPort) {
        self.viewPort = viewPort
    }
    
    func update(_ widget: DashboardWidget) {
        
        let group = DispatchGroup()
        
        group.enter()
//         + Double(arc4random_uniform(UInt32(10)) + 1)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.viewPort.didFinishUpdating()
        }
        
    }
    
}
