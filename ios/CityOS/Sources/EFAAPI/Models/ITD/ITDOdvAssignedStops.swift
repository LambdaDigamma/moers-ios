//
//  ITDOdvAssignedStops.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder
import CoreLocation

public struct ITDOdvAssignedStops: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let stops: [ITDOdvAssignedStop]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .element
    }
    
    enum CodingKeys: String, CodingKey {
        case stops = "itdOdvAssignedStop"
    }
    
}

public struct ITDOdvAssignedStop: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let name: String
    public let stopID: Int
    public let x: Double
    public let y: Double
    public let mapName: String
    public let value: String
    public let place: String
    public let nameWithPlace: String
    public let distanceTime: Int
    public let distance: Int?
    public let isTransferStop: Bool
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name:
                return .element
            default:
                return .attribute
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case name = ""
        case stopID = "stopID"
        case x = "x"
        case y = "y"
        case mapName = "mapName"
        case value = "value"
        case place = "place"
        case nameWithPlace = "nameWithPlace"
        case distanceTime = "distanceTime"
        case distance = "distance"
        case isTransferStop = "isTransferStop"
    }
    
    public var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: y, longitude: x)
    }
    
}
