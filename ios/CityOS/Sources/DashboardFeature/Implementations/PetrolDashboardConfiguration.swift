//
//  PetrolDashboardConfiguration.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation

public struct PetrolDashboardConfiguration: DashboardItemConfigurable {
    
    public var id: UUID
    
    public init() {
        self.id = UUID()
    }
    
}
