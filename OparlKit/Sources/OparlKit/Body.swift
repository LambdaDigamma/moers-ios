//
//  Body.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

public typealias SystemURL = String
public typealias ExternalListURL = String

/// The object type oparl:Body is used to represent an entity.
/// A body is in most cases a municipality, a city or a county.
/// As a rule, data from exactly one corporation is stored on an
/// OParl server and therefore only one body object is output.
/// However, if the server contains data from several entities,
/// a separate body object must be output for each entity.
public struct Body: Codable, Equatable {
    
    public let id: String?
    public let type: String?
    public let system: SystemURL?
    public let shortName: String?
    public let name: String
    public let website: String?
    public let license: String?
    public let licenseValidSince: Date?
    public let oparlSince: Date?
    public let ags: String?
    public let rgs: String?
    public let equivalent: [String]?
    public let contactEmail: String?
    public let contactName: String?
    public let organization: ExternalListURL
    public let person: ExternalListURL
    public let meeting: ExternalListURL
    public let paper: ExternalListURL
    public let legislativeTerm: [LegislativeTerm]
    public let agendaItem: ExternalListURL?
    public let consultation: ExternalListURL?
    public let file: ExternalListURL?
    public let locationList: ExternalListURL?
    public let legislativeTermList: ExternalListURL?
    public let membership: ExternalListURL?
    public let location: Location?
    public let keyword: [String]?
    public let created: Date?
    public let modified: Date?
    public let web: String?
    public let deleted: Bool?
    
}
