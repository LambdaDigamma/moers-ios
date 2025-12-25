//
//  RubbishCollectionItem.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import Core

public struct RubbishCollectionItem: Codable {
    
    public let date: String
    public let type: RubbishWasteType
    
    public var parsedDate: Date {
        return Date.from(date, withFormat: "dd.MM.yyyy") ?? Date()
    }
    
}
