//
//  ODVNameElement.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public typealias StatelessIdentifier = String

public struct ODVNameElement: Codable, DynamicNodeDecoding, BaseStubbable {
    
    public var id: Int?
    public var listIndex: Int?
    public var mapItemList: ITDMapItemList?
    public var name: String
    public var matchQuality: Int
    public var lat: Double?
    public var lng: Double?
    public var mapName: String?
    
    /// District code number of the element. Also known as 'Gemeindekennziffer' (GKZ or OMC).
    public var omc: Int?
    
    public var placeID: Int?
    public var type: ObjectFilter?
    public var anyType: TransitLocationType?
    public var locality: String?
    public var objectName: String?
    public var buildingName: String?
    public var buildingNumber: String?
    public var postcode: String?
    public var streetName: String?
    public var nameKey: String?
    public var mainLocality: String?
    public var stateless: StatelessIdentifier
    public var value: String?
    
    
    // Can be found in DM requests
    public var stopID: Stop.ID?
    public var isTransferStop: Bool?
    public var tariffArea: String?
    public var tariffAreaName: String?
    public var tariffLayer1: String?
    public var tariffLayer2: String?
    
    public enum CodingKeys: String, CodingKey {
        case listIndex
        case mapItemList = "itdMapItemList"
        case name = ""
        case locality
        case matchQuality
        case lng = "x"
        case lat = "y"
        case mapName
        case id
        case omc
        case placeID
        case type = "anyTypeSort"
        case anyType
        case objectName
        case buildingName
        case buildingNumber
        case postcode = "postCode"
        case streetName
        case nameKey
        case mainLocality
        case stateless
        case value
        
        case stopID = "stopID"
        case isTransferStop
        case tariffArea
        case tariffAreaName
        case tariffLayer1
        case tariffLayer2
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.mapItemList:
                return .element
            case CodingKeys.name:
                return .elementOrAttribute
            default:
                return .attribute
        }
    }
    
    public static func stub() -> ODVNameElement {
        return ODVNameElement(
            id: nil,
            listIndex: nil,
            mapItemList: nil,
            name: "Duisburg Hbf",
            matchQuality: 1,
            lat: 51.43045,
            lng: 6.77453,
            mapName: "WGS84[DD.DDDDD]",
            omc: 5112000,
            placeID: 20,
            type: nil,
            anyType: nil,
            locality: "Duisburg",
            objectName: "Duisburg Hbf",
            buildingName: "Duisburg Hbf",
            buildingNumber: "1",
            postcode: "47051",
            streetName: "Portsmouthplatz",
            nameKey: nil,
            mainLocality: "Duisburg",
            stateless: "",
            value: nil,
            stopID: 20016032,
            isTransferStop: nil,
            tariffArea: nil,
            tariffAreaName: nil,
            tariffLayer1: nil,
            tariffLayer2: nil
        )
    }
    
}
