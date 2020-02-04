//
//  DashboardItem.swift
//  Moers
//
//  Created by Lennart Fischer on 15.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
struct DashboardItem: Hashable {
    
    let name: String
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func ==(lhs: DashboardItem, rhs: DashboardItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
