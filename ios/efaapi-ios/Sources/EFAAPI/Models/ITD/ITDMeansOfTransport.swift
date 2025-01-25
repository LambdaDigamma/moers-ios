//
//  ITDMeansOfTransport.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import Foundation

import Foundation
import XMLCoder

public struct ITDMeansOfTransport: Codable, Equatable, Hashable, DynamicNodeDecoding, LineIdentifiable {
    
    public let name: String
    public let shortName: String
    public let symbol: String
    public let type: Int
    public let motType: TransportType?
    public let productName: String
    public let productId: Int?
    
    public let timetablePeriod: String?
    public let destination: String
    public let network: String
    public let ttb: Int
    public let stt: Int
    public let rop: Int
    public let destinationID: String?
    public let spTr: String?
    public let stateless: String
    public let tc: Int
    public let lineDisplay: String
    
    public let motDivaParams: MotDivaParams
    public let `operator`: ITDOperator?
    
    public var parsedDestinationID: Int? {
        guard let destinationID = destinationID else {
            return nil
        }
        return Int(destinationID) ?? nil
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case
                CodingKeys.operator,
                CodingKeys.motDivaParams
                :
                return .element
            default:
                return .attribute
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case shortName = "shortname"
        case symbol
        case type
        case motType
        case productName
        case productId
        case timetablePeriod
        case destination
        case network
        case ttb = "TTB"
        case stt = "STT"
        case rop = "ROP"
        case destinationID = "destID"
        case spTr = "spTr"
        case stateless
        case tc = "tC"
        case lineDisplay

        case motDivaParams = "motDivaParams"
        case `operator` = "itdOperator"
    }
    
    public var lineIdentifier: String {
        self.stateless
    }
    
}
