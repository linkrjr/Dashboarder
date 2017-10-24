//
//  Service.swift
//  Dashboarder_Example
//
//  Created by Ronaldo Gomes on 19/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class Service {
    
    func fetchCards(success: @escaping ([Card]) -> Void) {
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 5) {
            let quantity = arc4random_uniform(UInt32(10)) + 1
            success([Card(title: "title1", content: "content1") ])
        }
        
    }
    
}
