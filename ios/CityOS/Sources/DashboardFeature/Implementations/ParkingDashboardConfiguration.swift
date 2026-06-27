//
//  ParkingDashboardConfiguration.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

import Foundation

nonisolated public struct ParkingDashboardConfiguration: DashboardItemConfigurable {
    
    public var id: UUID
    
    public init() {
        self.id = UUID()
    }
    
}
