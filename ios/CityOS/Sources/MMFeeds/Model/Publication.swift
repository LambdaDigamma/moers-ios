//
//  Publication.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation

public struct Publication: Codable, Equatable, Hashable {
    var order: Int?
    var createdAt: Date? = Date()
    var updatedAt: Date? = Date()
    
    public enum CodingKeys: String, CodingKey {
        case order = "order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
