//
//  DepartureMonitorRequest.swift
//  
//
//  Created by Lennart Fischer on 18.04.21.
//

import Foundation
import XMLCoder

public struct DepartureMonitorRequest: Codable, DynamicNodeDecoding {
        
    public let requestID: Int
    public let odv: ODV
    public var date: ITDDateTime
    public var dmDateTime: ITDDMDateTime
    public var dateRange: ITDDateRange
//    public var tripOptions: ITDTripOptions
    public var servingLines: ITDServingLines
    public var departures: ITDDepartureList
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.requestID:
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case requestID
        case odv = "itdOdv"
        case date = "itdDateTime"
        case dmDateTime = "itdDMDateTime"
        case dateRange = "itdDateRange"
//        case tripOptions = "itdTripOptions"
        case servingLines = "itdServingLines"
        case departures = "itdDepartureList"
    }
    
}
