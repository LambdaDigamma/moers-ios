//
//  Organisation.swift
//  Moers
//
//  Created by Lennart Fischer on 23.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct Organisation: Codable/*, Timestamp*/ {
    
    var id: Int
    var name: String
    var description: String
    var entryID: Int?
    var iconURL: URL?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    
    
//    var entry: Entry?
    
}

extension Organisation {
    
    init(id: Int, name: String, description: String, entryID: Int?, iconURL: URL?) {
        self.id = id
        self.name = name
        self.description = description
        self.entryID = entryID
        self.iconURL = iconURL
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
}
