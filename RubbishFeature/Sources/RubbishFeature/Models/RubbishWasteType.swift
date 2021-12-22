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
    
    public static func localizedForCase(_ wasteType: RubbishWasteType) -> String {
        
        switch wasteType {
            case .cuttings: return String.localized("GreenWaste")
            case .organic: return String.localized("OrganicWaste")
            case .paper: return String.localized("PaperWaste")
            case .residual: return String.localized("ResidualWaste")
            case .plastic: return String.localized("YellowWaste")
        }
        
    }
    
    var title: String {
        
        switch self {
            case .cuttings: return String.localized("GreenWaste")
            case .organic: return String.localized("OrganicWaste")
            case .paper: return String.localized("PaperWaste")
            case .residual: return String.localized("ResidualWaste")
            case .plastic: return String.localized("YellowWaste")
        }
        
    }
    
    var shortName: String {
        
        switch self {
            case .cuttings: return PackageStrings.WasteShort.green
            case .organic: return PackageStrings.WasteShort.organic
            case .paper: return PackageStrings.WasteShort.paper
            case .residual: return PackageStrings.WasteShort.residual
            case .plastic: return PackageStrings.WasteShort.yellow
        }
        
    }
    
}
