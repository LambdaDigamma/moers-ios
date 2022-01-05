//
//  User.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import MMCommon
import Core

struct User {
    
    var type: UserType
    var id: Int?
    var name: String?
    var description: String?
    
    enum UserType: String, Localizable, CaseIterable, CaseName {
        
        case citizen = "citizen"
        case tourist = "tourist"
        
        static func localizedForCase(_ type: User.UserType) -> String {
            switch type {
                case .citizen: return String.localized("Citizen")
                case .tourist: return String.localized("Tourist")
            }
        }
        
        var name: String {
            switch self {
                case .citizen:
                    return String.localized("Citizen")
                case .tourist:
                    return String.localized("Tourist")
            }
        }
        
    }
    
}
