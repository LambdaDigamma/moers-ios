//
//  ITDPartialRoute.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation
import XMLCoder

public struct ITDPartialRoute: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    public let type: String
    public let active: String
    public let timeMinute: Int
    public let distance: Int?
    public let bookingCode: String
    public let partialRouteType: String

    public let bufBef: Int
    public let bufAft: Int

    public let points: [ITDPoint]
    public let meansOfTransport: ITDMeansOfTransport
    public let infoTextList: ITDInfoTextList?
    
    public let footPathInfo: ITDFootPathInfo?
    public let realtimeStatus: ITDRBLControlled?
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case
                CodingKeys.type,
                CodingKeys.active,
                CodingKeys.timeMinute,
                CodingKeys.distance,
                CodingKeys.bookingCode,
                CodingKeys.partialRouteType,
                CodingKeys.bufBef,
                CodingKeys.bufAft
                :
                return .attribute
            default:
                return .element
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case active = "active"
        case timeMinute
        case distance = "distance"
        case bookingCode
        case partialRouteType

        case bufBef
        case bufAft

        case points = "itdPoint"
        case meansOfTransport = "itdMeansOfTransport"
        case infoTextList = "itdInfoTextList"
        
        case footPathInfo = "itdFootPathInfo"
        case realtimeStatus = "itdRBLControlled"
    }
    
}
