//
//  PetrolType.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
public enum PetrolType: String, Codable, CaseIterable, Equatable {
    
    case diesel = "diesel"
    case e5 = "e5"
    case e10 = "e10"
    
}
