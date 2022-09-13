//
//  Membership.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

public struct Membership: Codable, Equatable, Hashable {
    
    public let id: String?
    public let type: String?
    public let person: PersonURL?
    public let organization: OrganizationURL?
    public let votingRight: Bool?
//    public let startDate: date
//    public let endDate: date
    public let onBehalfOf: OrganizationURL?
    public let license: String?
    public let keyword: [String]?
    public let created: Date?
    public let modified: Date?
    public let web: String?
    public let deleted: Bool?
    
}
