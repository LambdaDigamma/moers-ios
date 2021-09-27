//
//  RadioBroadcast.swift
//  
//
//  Created by Lennart Fischer on 23.09.21.
//

import Foundation

public struct RadioBroadcast: Codable, Identifiable {
    
    public typealias ID = Int
    public typealias UID = String
    
    public var id: ID
    public var uid: UID
    public var title: String
    public var description: String?
    public var startsAt: Date?
    public var endsAt: Date?
    public var url: String?
    public var attach: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public init(
        id: ID,
        uid: UID,
        title: String,
        description: String? = nil,
        startsAt: Date? = nil,
        endsAt: Date? = nil,
        url: String? = nil,
        attach: String? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date()
    ) {
        self.id = id
        self.uid = uid
        self.title = title
        self.description = description
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.url = url
        self.attach = attach
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case uid = "uid"
        case title = "title"
        case description = "description"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case url = "url"
        case attach = "attach"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
}
