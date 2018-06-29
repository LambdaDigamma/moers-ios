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
    private let kUserName = "userName"
    private let kUserID = "userID"
    private let kDescription = "userDescription"
    
    var user: User {
        return loadUser()
    }
    
    var loggedIn: Bool {
        return UserDefaults.standard.integer(forKey: kUserID) != 0 && UserDefaults.standard.string(forKey: kUserName) == nil
    }
    
    func register(_ user: User) {
        
        UserDefaults.standard.set(user.type.rawValue, forKey: kUserType)
        UserDefaults.standard.set(user.name, forKey: kUserName)
        UserDefaults.standard.set(user.id, forKey: kUserID)
        UserDefaults.standard.set(user.description, forKey: kDescription)
        
    }
    
    private func loadUser() -> User {
        
        let userTypeString = UserDefaults.standard.string(forKey: kUserType) ?? "tourist"
        let userName = UserDefaults.standard.string(forKey: kUserName)
        let userID = UserDefaults.standard.integer(forKey: kUserID)
        let userDescription = UserDefaults.standard.string(forKey: kDescription)
        
        let userType = User.UserType(rawValue: userTypeString) ?? .tourist
        
        let user = User(type: userType, id: userID, name: userName, description: userDescription)
        
        return user
        
    }
    
    public var theme: Theme {
        get {
            
            let identifier = UserDefaults.standard.string(forKey: "Theme") ?? Theme.lightning.identifier
            
            let theme = Theme.all.filter { $0.identifier == identifier }.first ?? Theme.lightning
            
            return theme
            
        }
        set {
            UserDefaults.standard.set(newValue.identifier, forKey: "Theme")
        }
    }
    
}
