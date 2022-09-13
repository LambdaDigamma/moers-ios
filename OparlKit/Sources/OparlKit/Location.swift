//
//  Location.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

public typealias BodyURL = String
public typealias OrganizationURL = String
public typealias PersonURL = String
public typealias MeetingURL = String
public typealias PaperURL = String

public struct Location: Codable, Equatable, Hashable {
    
    public let id: String?
    public let type: String?
    public let description: String?
//    public let geoJSON: GeoJson
    public let streetAddress: String?
    public let room: String?
    public let postalCode: String?
    public let subLocality: String?
    public let locality: String?
    public let bodies: [BodyURL]?
    public let organizations: [OrganizationURL]?
    public let persons: [PersonURL]?
    public let meetings: [MeetingURL]?
    public let papers: [PaperURL]?
    public let license: String?
    public let keyword: [String]?
    public let created: Date?
    public let modified: Date?
    public let web: String?
    public let deleted: Bool?
    
}
