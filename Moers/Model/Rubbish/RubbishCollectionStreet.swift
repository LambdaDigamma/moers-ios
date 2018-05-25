//
//  RubbishCollectionStreet.swift
//  Moers
//
//  Created by Lennart Fischer on 19.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

enum RubbishWasteType: String {
    case residual = "Restabfall"
    case organic = "Biotonne"
    case paper = "Papiertonne"
    case yellow = "Gelber Sack"
    case green = "Grünschnitt"
}

struct RubbishCollectionStreet {
    
    var street: String
    var residualWaste: Int
    var organicWaste: Int
    var paperWaste: Int
    var yellowBag: Int
    var greenWaste: Int
    var sweeperDay: String
    
}
