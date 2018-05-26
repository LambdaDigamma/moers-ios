//
//  UserManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct UserManager {
    
    static var shared = UserManager()
    
    private let kUserType = "userType"
    
    var user: User {
        return loadUser()
    }
    
    func register(_ user: User) {
        
        UserDefaults.standard.set(user.type.rawValue, forKey: kUserType)
        
    }
    
    private func loadUser() -> User {
        
        let userTypeString = UserDefaults.standard.string(forKey: kUserType) ?? "tourist"
        
        let userType = User.UserType(rawValue: userTypeString) ?? .tourist
        
        let user = User(type: userType)
        
        return user
        
    }
    
}
