//
//  ITDDeparture.swift
//  
//
//  Created by Lennart Fischer on 19.04.21.
//

import Foundation
import XMLCoder

public struct ITDDeparture: Codable, DynamicNodeDecoding, BaseStubbable, Equatable {
    
    public var regularDateTime: ITDDateTime
    public var actualDateTime: ITDDateTime?
    public var servingLine: ITDServingLine
    
    public var stopID: Stop.ID
    public var stopName: String
    public var nameWO: String
    public var latitude: Double
    public var longitude: Double
    public var platform: String
    public var platformName: String?
    public var plannedPlatformName: String?
    public var countdown: Int
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.stopID, CodingKeys.longitude, CodingKeys.latitude,
                 CodingKeys.platform, CodingKeys.platformName, CodingKeys.plannedPlatformName,
                 CodingKeys.stopName, CodingKeys.nameWO,
                 CodingKeys.countdown:
                return .attribute
            default:
                return .elementOrAttribute
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case servingLine = "itdServingLine"
        case regularDateTime = "itdDateTime"
        case actualDateTime = "itdRTDateTime"
        case stopID = "stopID"
        case stopName = "stopName"
        case nameWO = "nameWO"
        case longitude = "x"
        case latitude = "y"
        case platform = "platform"
        case platformName = "platformName"
        case plannedPlatformName = "plannedPlatformName"
        case countdown = "countdown"
    }
    
    public static func stub() -> ITDDeparture {
        return ITDDeparture(
            regularDateTime: ITDDateTime.stub(),
            actualDateTime: nil,
            servingLine: ITDServingLine.stub(),
            stopID: 0,
            stopName: "Duisburg Hbf",
            nameWO: "Duisburg Hbf",
            latitude: 51.43203,
            longitude: 6.77828,
            platform: "5",
            platformName: nil,
            plannedPlatformName: nil,
            countdown: 0
        )
    }
    
}
