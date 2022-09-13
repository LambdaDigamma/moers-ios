//
//  LegislativeTerm.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

public struct LegislativeTerm: Codable, Equatable {
    
    public let id: String?
    public let type: String?
    public let body: BodyURL?
    public let name: String?
//    public let startDate: Date?
//    public let endDate: Date?
    public let license: String?
    public let keyword: [String]?
    public let created: Date?
    public let modified: Date?
    public let web: String?
    public let deleted: Bool?
    
}
