//
//  User.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct User {
    
    var type: UserType
    var id: Int?
    var name: String?
    var description: String?
    
    enum UserType: String {
        case tourist = "tourist"
        case citizen = "citizen"
    }
    
}
