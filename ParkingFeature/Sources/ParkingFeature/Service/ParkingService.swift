//
//  ParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Combine

public protocol ParkingService {
    
    func loadDashboard() -> AnyPublisher<ParkingDashboardData, Error>
    
    func loadParkingAreas() -> AnyPublisher<[ParkingArea], Error>
    
}
