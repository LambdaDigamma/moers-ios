//
//  RubbishCollectionItem.swift
//  Moers
//
//  Created by Lennart Fischer on 20.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

// TODO: Implement Localizable

struct RubbishCollectionItem {
    
    let date: String
    let type: RubbishWasteType
    
    var parsedDate: Date {
        return Date.from(date, withFormat: "dd.MM.yyyy") ?? Date()
    }
    
}
