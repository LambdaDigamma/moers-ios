//
//  Person.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

public typealias LocationURL = String

/// Every natural person who is active in parliamentary work and,
/// in particular, is a member of a grouping (`Organization`)
/// is represented with an object of type `Person`.
public struct Person: Codable, Equatable, Identifiable, Hashable {
    
    public let id: String?
    public let type: String?
    public let body: BodyURL?
    public let name: String?
    public let familyName: String?
    public let givenName: String?
    public let formOfAddress: String?
    public let affix: String?
    public let title: [String]?
    public let gender: String?
    public let phone: [String]?
    public let email: [String]?
    public let location: LocationURL?
    public let locationObject: Location?
    public let status: [String]?
    public let membership: [Membership]?
    public let life: String?
    public let lifeSource: String?
    public let license: String?
    public let keyword: [String]?
    public let created: Date?
    public let modified: Date?
    public let web: String?
    public let deleted: Bool?
    
}
