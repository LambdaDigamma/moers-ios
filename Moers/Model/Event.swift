//
//  Event.swift
//  Moers
//
//  Created by Lennart Fischer on 14.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct Event: Codable, Timestamp {
    
    let id: Int
    let name: String
    let description: String
    let url: String?
    let date: String
    let timeStart: String
    let timeEnd: String?
    let category: String?
    let organisationID: Int?
    let entryID: Int?
    let organisation: Organisation?
    let entry: Entry?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var parsedDate: Date {
        return Date.from(date, withFormat: "dd.MM.yyyy") ?? Date()
    }
    
    var parsedTime: String {
        
        if let timeEnd = timeEnd {
            return timeStart + " - " + timeEnd
        } else {
            return timeStart
        }
        
    }
    
}
