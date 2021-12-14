//
//  RubbishWasteType.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import MMCommon

public enum RubbishWasteType: String, Localizable, Codable, Equatable, Hashable, CaseIterable {
    
    case residual // = "Restabfall"
    case organic // = "Biotonne"
    case paper // = "Papiertonne"
    case plastic // = "Gelber Sack"
    case cuttings // = "Grünschnitt"
    
    public static func localizedForCase(_ c: RubbishWasteType) -> String {
        
        switch c {
            case .cuttings: return String.localized("GreenWaste")
            case .organic: return String.localized("OrganicWaste")
            case .paper: return String.localized("PaperWaste")
            case .residual: return String.localized("ResidualWaste")
            case .plastic: return String.localized("YellowWaste")
        }
        
    }
    
}
