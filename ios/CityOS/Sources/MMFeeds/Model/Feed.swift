//
//  Feed.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation

public struct Feed: BaseFeed {
     
    
    public typealias ID = Int
    
    public var id: ID = 0
    public var name: String
    public var posts: [Post] = []
    public var createdAt: Date? = Date()
    public var updatedAt: Date? = Date()
    
    public static func stub(withID id: Int) -> Feed {
        return Feed(id: id,
                    name: "Test Feed",
                    posts: [])
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case posts = "posts"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        return decoder
    }
    
}
