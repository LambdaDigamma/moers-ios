//
//  ITDServingLine.swift
//  
//
//  Created by Lennart Fischer on 19.04.21.
//

import Foundation
import XMLCoder

public struct ITDServingLine: Codable, Equatable, DynamicNodeDecoding, BaseStubbable {
    
    public var direction: String
    public var directionFrom: String?
    public var descriptionText: String
    public var code: String
    public var number: String
    public var symbol: String
    public var `operator`: ITDOperator?
    public var destinationID: String
    public var transportType: TransportType
    public var noTrain: ITDNoTrain
    
    public var productID: Int
    public var stateless: String
    public var realtime: Bool // TODO: Validate whether this decoding works.
    public var valid: String?
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.operator, CodingKeys.descriptionText, CodingKeys.noTrain:
                return .element
            case CodingKeys.direction, CodingKeys.stateless,
                 CodingKeys.destinationID, CodingKeys.realtime,
                 CodingKeys.valid, CodingKeys.code, CodingKeys.number,
                 CodingKeys.symbol, CodingKeys.transportType, CodingKeys.productID, CodingKeys.directionFrom:
                return .attribute
            default:
                return .elementOrAttribute
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case descriptionText = "itdRouteDescText"
        case `operator` = "itdOperator"
        case direction = "direction"
        case directionFrom = "directionFrom"
        case stateless = "stateless"
        case destinationID = "destID"
        case realtime = "realtime"
        case valid = "valid"
        case code = "code"
        case number = "number"
        case symbol = "symbol"
        case transportType = "motType"
        case productID = "productId"
        case noTrain = "itdNoTrain"
    }
    
    public static func stub() -> ITDServingLine {
        return ITDServingLine(
            direction: "DU-Hbf",
            directionFrom: nil,
            descriptionText: "Geldern Bf - Kamp-Lintfort - Moers - Duisburg Hbf",
            code: "5",
            number: "SB30",
            symbol: "SB30",
            operator: nil,
            destinationID: "",
            transportType: .rapidBus,
            noTrain: ITDNoTrain(name: "Niederflurbus", fullName: nil, delay: nil),
            productID: 0,
            stateless: "",
            realtime: false,
            valid: nil
        )
    }
    
}
