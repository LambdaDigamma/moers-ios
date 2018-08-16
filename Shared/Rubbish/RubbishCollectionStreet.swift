//
//  RubbishCollectionStreet.swift
//  Moers
//
//  Created by Lennart Fischer on 19.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

enum RubbishWasteType: String, Localizable {
    
    case residual = "Restabfall"
    case organic = "Biotonne"
    case paper = "Papiertonne"
    case yellow = "Gelber Sack"
    case green = "Grünschnitt"
    
    static func localizedForCase(_ c: RubbishWasteType) -> String {
        
        switch c {
        case .green: return String.localized("GreenWaste")
        case .organic: return String.localized("OrganicWaste")
        case .paper: return String.localized("PaperWaste")
        case .residual: return String.localized("ResidualWaste")
        case .yellow: return String.localized("YellowWaste")
        }
        
    }
    
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
