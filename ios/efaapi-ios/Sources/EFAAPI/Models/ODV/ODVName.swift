//
//  ODVName.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public struct ODVName: Codable, DynamicNodeDecoding, BaseStubbable {
    
    public var state: String
    public var method: String?
    public var elements: [ODVNameElement]?
    public var input: ODVNameInput?
    
    public enum CodingKeys: String, CodingKey {
        case state
        case method
        case elements = "odvNameElem"
        case input = "odvNameInput"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.state:
                return .attribute
            case CodingKeys.method:
                return .attribute
            default:
                return .element
        }
    }
    
    public static func stub() -> ODVName {
        return ODVName(
            state: "identified",
            method: nil,
            elements: nil,
            input: nil
        )
    }
    
}
