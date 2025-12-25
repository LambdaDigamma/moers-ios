//
//  GeoObjectLineResponse.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import XMLCoder

public struct GeoObjectLineResponse: Codable, DynamicNodeDecoding {
    
    public let lineItemList: LineItemList
    
    enum CodingKeys: String, CodingKey {
        case lineItemList = "lineItemList"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.lineItemList:
                return .element
            default:
                return .element
        }
    }
    
}

public struct LineItemList: Codable, DynamicNodeDecoding {
    
    public let lineItems: [LineItem]
    
    enum CodingKeys: String, CodingKey {
        case lineItems = "lineItem"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.lineItems:
                return .element
            default:
                return .element
        }
    }
    
}

#if canImport(MapKit)
import MapKit
#endif

public struct LineItem: Codable, DynamicNodeDecoding {
    
    public let completePath: Bool
    public let servingLine: ITDServingLine
    public let pathCoordinates: [ITDPathCoordinates]
    public let points: [ITDPoint]
    
    enum CodingKeys: String, CodingKey {
        case completePath = "completePath"
        case servingLine = "itdServingLine"
        case pathCoordinates = "itdPathCoordinates"
        case points = "itdPoint"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.completePath:
                return .attribute
            case CodingKeys.servingLine:
                return .element
            case CodingKeys.pathCoordinates:
                return .element
            case CodingKeys.points:
                return .element
            default:
                return .element
        }
    }
    
    #if canImport(MapKit)
    
    public func toPolyline() -> [MKPolyline] {
        
        let coordinatesOfPolylines = pathCoordinates.map { (coordinates: ITDPathCoordinates) in
            coordinates.coordinateBaseElemList.coordinates.map { (elem: ITDCoordinateBaseElem) in
                return CLLocationCoordinate2D(latitude: elem.y, longitude: elem.x)
            }
        }
        
        return coordinatesOfPolylines.map {
            return MKPolyline(coordinates: $0, count: $0.count)
        }
        
    }
    
    #endif
    
}
