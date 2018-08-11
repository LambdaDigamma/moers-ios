//
//  PetrolType.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

enum PetrolType: String, Codable, EnumCollection, Localizable {
    
    case diesel = "diesel"
    case e5 = "e5"
    case e10 = "e10"
    
    static func localizedForCase(_ c: PetrolType) -> String {
        
        switch c {
        case .diesel: return String.localized("Diesel")
        case .e10: return String.localized("E5")
        case .e5: return String.localized("E10")
        }
        
    }
    
}
