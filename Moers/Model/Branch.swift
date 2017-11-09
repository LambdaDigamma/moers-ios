//
//  Branch.swift
//  Moers
//
//  Created by Lennart Fischer on 06.11.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation
import InfoKit

struct Branches: Codable {
    
    let branches: [Branch]
    
}

struct Branch: Codable {
    
    let name: String
    let color: String
    
}
