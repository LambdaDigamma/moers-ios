//
//  StaticParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Combine

public class StaticParkingService: ParkingService {
    
    public var retrieveParkingAreas: () -> [ParkingArea]
    
    public init(oldData: Bool = false) {
        
        self.retrieveParkingAreas = {
            return [
                .init(
                    id: 1,
                    name: "Kauzstr.",
                    capacity: 62,
                    occupiedSites: 51,
                    updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                ),
                .init(
                    id: 2,
                    name: "Bankstr.",
                    capacity: 139,
                    occupiedSites: 137
                ),
                .init(
                    id: 3,
                    name: "Kastell",
                    capacity: 200,
                    occupiedSites: 124
                ),
                .init(
                    id: 4,
                    name: "Mühlenstr.",
                    capacity: 709,
                    occupiedSites: 5
                )
            ]
        }
        
        if oldData {
            
            self.retrieveParkingAreas = {
                return [
                    .init(
                        id: 1,
                        name: "Kauzstr.",
                        capacity: 62,
                        occupiedSites: 51,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    ),
                    .init(
                        id: 2,
                        name: "Bankstr.",
                        capacity: 139,
                        occupiedSites: 137,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    ),
                    .init(
                        id: 3,
                        name: "Kastell",
                        capacity: 200,
                        occupiedSites: 124,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    ),
                    .init(
                        id: 4,
                        name: "Mühlenstr.",
                        capacity: 709,
                        occupiedSites: 5,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    )
                ]
            }
            
        }
        
    }
    
    public func loadParkingAreas() -> AnyPublisher<[ParkingArea], Error> {
        
        return Just(retrieveParkingAreas())
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
    public func loadDashboard() -> AnyPublisher<ParkingDashboardData, Error> {
        
        let parkingAreas = retrieveParkingAreas()
        
        return Just(ParkingDashboardData(parkingAreas: parkingAreas))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
}
