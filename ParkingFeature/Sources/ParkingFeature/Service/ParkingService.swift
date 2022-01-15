//
//  ParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Combine

public protocol ParkingService {
    
    func loadParkingAreas() -> AnyPublisher<[ParkingArea], Error>
    
}
