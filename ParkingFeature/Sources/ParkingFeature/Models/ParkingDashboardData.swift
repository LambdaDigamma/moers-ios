//
//  ParkingDashboardData.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

import Foundation
import ModernNetworking

public struct ParkingDashboardData: Model {
    
    public let parkingAreas: [ParkingArea]
    
    public init(parkingAreas: [ParkingArea] = []) {
        self.parkingAreas = parkingAreas
    }
    
    public enum CodingKeys: String, CodingKey {
        case parkingAreas = "parking_areas"
    }
    
}
