//
//  User.swift
//  Moers
//
//  Created by Lennart Fischer on 29.03.20.
//

import Foundation

public struct User {
    
    public init(type: User.UserType, id: Int? = nil, name: String? = nil, description: String? = nil) {
        self.type = type
        self.id = id
        self.name = name
        self.description = description
    }
    
    public var type: UserType
    public var id: Int?
    public var name: String?
    public var description: String?
    
    public enum UserType: String, CaseIterable, CaseName {
        
        case citizen = "citizen"
        case tourist = "tourist"
        
        public var name: String {
            switch self {
                case .citizen: return String(localized: "Citizen", bundle: .module)
                case .tourist: return String(localized: "Tourist", bundle: .module)
            }
        }
        
    }
    
}
