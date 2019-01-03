//
//  Audit.swift
//  Moers
//
//  Created by Lennart Fischer on 31.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct Audit: Codable {
    
    let id: Int
    let event: String
    let oldValues: [String: String]
    let newValues: [String: String]
    let updatedAt: Date?
    let createdAt: Date?
    
}
