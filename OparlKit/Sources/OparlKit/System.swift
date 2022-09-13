//
//  System.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

public struct System: Codable, Equatable {
    
    public let id: String?
    public let type: String?
    public let oparlVersion: String
    public let otherOparlVersions: [String]?
    public let license: String?
    public let body: String
    public let name: String?
    public let contactEmail: String?
    public let contactName: String?
    public let website: String?
    public let vendor: String?
    public let product: String?
    public let created: Date?
    public let modified: Date?
    public let web: String?
    public let deleted: Bool?
    
}
