//
//  StaticParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Core

public class StaticParkingService: ParkingService {
    
    public var retrieveParkingAreas: () -> [ParkingArea]
    
    public init(oldData: Bool = false) {
        
        self.retrieveParkingAreas = {
            return [
                .init(
                    id: 1,
                    name: "Kauzstr.",
                    location: Point(latitude: 51.452, longitude: 6.627),
                    capacity: 62,
                    occupiedSites: 51,
                    updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                ),
                .init(
                    id: 2,
                    name: "Bankstr.",
                    location: Point(latitude: 51.450, longitude: 6.632),
                    capacity: 139,
                    occupiedSites: 137
                ),
                .init(
                    id: 3,
                    name: "Kastell",
                    location: Point(latitude: 51.448, longitude: 6.624),
                    capacity: 200,
                    occupiedSites: 124
                ),
                .init(
                    id: 4,
                    name: "Mühlenstr.",
                    location: Point(latitude: 51.453, longitude: 6.621),
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
                        location: Point(latitude: 51.452, longitude: 6.627),
                        capacity: 62,
                        occupiedSites: 51,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    ),
                    .init(
                        id: 2,
                        name: "Bankstr.",
                        location: Point(latitude: 51.450, longitude: 6.632),
                        capacity: 139,
                        occupiedSites: 137,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    ),
                    .init(
                        id: 3,
                        name: "Kastell",
                        location: Point(latitude: 51.448, longitude: 6.624),
                        capacity: 200,
                        occupiedSites: 124,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    ),
                    .init(
                        id: 4,
                        name: "Mühlenstr.",
                        location: Point(latitude: 51.453, longitude: 6.621),
                        capacity: 709,
                        occupiedSites: 5,
                        updatedAt: Date.init(timeIntervalSinceNow: -2 * 24 * 60 * 60)
                    )
                ]
            }
            
        }
        
    }
    
    public func loadParkingAreas() async throws -> [ParkingArea] {
        return retrieveParkingAreas()
    }
    
    public func loadDashboard() async throws -> ParkingDashboardData {
        let parkingAreas = retrieveParkingAreas()
        return ParkingDashboardData(parkingAreas: parkingAreas)
    }
    
}
