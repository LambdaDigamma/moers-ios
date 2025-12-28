//
//  ParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation

public protocol ParkingService {
    
    func loadDashboard() async throws -> ParkingDashboardData
    
    func loadParkingAreas() async throws -> [ParkingArea]
    
}
