//
//  PetrolType.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import Core

// swiftlint:disable identifier_name
public enum PetrolType: String, Codable, CaseIterable, Equatable, CaseName {
    
    case diesel = "diesel"
    case e5 = "e5"
    case e10 = "e10"
    
    public var name: String {
        switch self {
            case .diesel:
                return "Diesel"
            case .e5:
                return "E5"
            case .e10:
                return "E10"
        }
    }
    
}
