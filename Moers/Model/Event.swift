//
//  Event.swift
//  Moers
//
//  Created by Lennart Fischer on 14.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct Event: Codable {
    
    let id: Int
    let name: String
    let url: String?
    let date: String
    let timeStart: String
    let timeEnd: String?
    let category: String
    
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
