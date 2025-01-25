//
//  ODV.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public extension Collection where Element == ODV {
    
    var origin: ODV? {
        return self.first(where: { $0.usage == .origin })
    }
    
    var destination: ODV? {
        return self.first(where: { $0.usage == .destination })
    }
    
}

/// ODV is an abbreviation for "origin destination via" and is used to verify points using the EFAs location server.
/// It refers to the role that the point has within a request.
/// The determination of points (stops, addresses, points of interest, ...) using the
/// EFA Location Server is outlined. ODVs allow a single field search.
public struct ODV: Codable, DynamicNodeDecoding {
    
    public var type: String
    public var usage: ODVUsageType
    public var objectFilter: ObjectFilter
    public var place: ODVPlace
    public var name: ODVName? = nil
    public var assignedStops: ITDOdvAssignedStops?

    public enum CodingKeys: String, CodingKey {
        case type
        case usage
        case objectFilter = "anyObjFilter"
        case place = "itdOdvPlace"
        case name = "itdOdvName"
        case assignedStops = "itdOdvAssignedStops"
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try container.decode(String.self, forKey: .type)
        self.usage = try container.decode(ODVUsageType.self, forKey: .usage)
        self.objectFilter = try container.decode(ObjectFilter.self, forKey: .objectFilter)
        self.place = try container.decode(ODVPlace.self, forKey: .place)
        self.name = try container.decode(ODVName?.self, forKey: .name)
        self.assignedStops = try container.decode(ITDOdvAssignedStops?.self, forKey: .assignedStops)
        
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.type:
                return .attribute
            case CodingKeys.usage:
                return .attribute
            case CodingKeys.objectFilter:
                return .attribute
            default:
                return .element
        }
    }
    
}
