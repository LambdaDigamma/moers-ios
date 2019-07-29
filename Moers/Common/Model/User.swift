//
//  User.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import MMAPI

struct User {
    
    var type: UserType
    var id: Int?
    var name: String?
    var description: String?
    
    enum UserType: String, EnumCollection, Localizable, CaseIterable {
        
        case citizen = "citizen"
        case tourist = "tourist"
        
        static func localizedForCase(_ c: User.UserType) -> String {
            switch c {
            case .citizen: return String.localized("Citizen")
            case .tourist: return String.localized("Tourist")
            }
        }
        
    }
    
}
