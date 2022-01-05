//
//  RubbishWasteType.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import SwiftUI

public enum RubbishWasteType: String, Codable, Equatable, Hashable, CaseIterable {
    
    case residual = "residual"
    case organic = "organic"
    case paper = "paper"
    case plastic = "plastic"
    case cuttings = "cuttings"
    
    public var title: String {
        
        switch self {
            case .cuttings: return PackageStrings.WasteType.green
            case .organic: return PackageStrings.WasteType.organic
            case .paper: return PackageStrings.WasteType.paper
            case .residual: return PackageStrings.WasteType.residual
            case .plastic: return PackageStrings.WasteType.yellow
        }
        
    }
    
    public var shortName: String {
        
        switch self {
            case .cuttings: return PackageStrings.WasteShort.green
            case .organic: return PackageStrings.WasteShort.organic
            case .paper: return PackageStrings.WasteShort.paper
            case .residual: return PackageStrings.WasteShort.residual
            case .plastic: return PackageStrings.WasteShort.yellow
        }
        
    }
    
    public var backgroundColor: Color {
        
        switch self {
            case .cuttings:
                return Color.green
            case .organic:
                return Color.green
            case .paper:
                return Color.blue
            case .residual:
                return Color.gray
            case .plastic:
                return Color.yellow
        }
        
    }
    
}
