//
//  ParkingAreaViewModel.swift
//  
//
//  Created by Lennart Fischer on 14.01.22.
//

import Foundation
import Core
import MapKit

public class ParkingAreaViewModel: ObservableObject, Identifiable {
    
    public let id: UUID = UUID()
    public let title: String
    public let free: Int
    public let total: Int
    public let currentOpeningState: ParkingAreaOpeningState
    public let updatedAt: Date
    
    @Published var location: Point?
    @Published var region: MKCoordinateRegion = .init(
        center: CoreSettings.regionCenter,
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
    
    @Published var openingHours: DataState<[OpeningHourEntry], Error> = .loading
    
    public init(
        title: String,
        free: Int,
        total: Int,
        location: Point? = nil,
        currentOpeningState: ParkingAreaOpeningState,
        updatedAt: Date
    ) {
        self.title = title
        self.free = free
        self.total = total
        self.location = location
        self.currentOpeningState = currentOpeningState
        self.updatedAt = updatedAt
        
        if let location = location {
            self.region.center = location.toCoordinate()
        }
        
    }
    
    public var percentage: Double {
        
        if total <= 0 {
            return 1
        }
        
        return 1.0 - Double(free) / Double(total)
    }
    
    public func load() {
        
        self.openingHours = .success([
            .init(text: "Mo-Fr", time: "09:00 - 19:00"),
            .init(text: "Sa", time: "10:00 - 16:00"),
        ])
        
    }
    
}
