//
//  ParkingArea.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Core

public struct ParkingArea: Equatable, Identifiable, Codable, Stubbable {
    
    public typealias ID = Int
    
    public let id: ParkingArea.ID
    public let name: String
    public let location: Point?
    public let currentOpeningState: ParkingAreaOpeningState
    public let capacity: Int?
    public let occupiedSites: Int?
    
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: ParkingArea.ID,
        name: String,
        location: Point? = nil,
        currentOpeningState: ParkingAreaOpeningState = .open,
        capacity: Int?,
        occupiedSites: Int?,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date()
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.currentOpeningState = currentOpeningState
        self.capacity = capacity
        self.occupiedSites = occupiedSites
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Calculates the number of free parking sites
    /// based on the parking areas capacity and the
    /// number of currently occupied sites.
    public var freeSites: Int {
        return (capacity ?? 0) - (occupiedSites ?? 0)
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case location = "location"
        case currentOpeningState = "current_opening_state"
        case capacity = "capacity"
        case occupiedSites = "occupied_sites"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public static func stub(withID id: Int) -> ParkingArea {
        return ParkingArea(
            id: id,
            name: "Mühlenstr.",
            location: nil,
            currentOpeningState: .open,
            capacity: 700,
            occupiedSites: 350
        )
    }
    
}

/// Represents the possible opening states of a parking area.
public enum ParkingAreaOpeningState: String, Equatable, Codable, CaseIterable {
    
    case `open` = "open"
    case unknown = "unknown"
    case closed = "closed"
    
}
