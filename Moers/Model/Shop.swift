//
//  Shop.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

enum Weekday: Int {
    
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
}

struct OpeningHours {
    var monday_from: String
    var monday_till: String
    var monday_break: String?
    var tuesday_from: String
    var tuesday_till: String
    var tuesday_break: String?
    var wednesday_from: String
    var wednesday_till: String
    var wednesday_break: String?
    var thursday_from: String
    var thursday_till: String
    var thursday_break: String?
    var friday_from: String
    var friday_till: String
    var friday_break: String?
    var saturday_from: String
    var saturday_till: String
    var saturday_break: String?
    var other: String?
    
    func createOpeningTimes(from start: String, till end: String, withBreak interval: String?) -> String {
        
        let fullString: String
        
        if let i = interval {
            
            if i.components(separatedBy: " - ").count == 2  {
                
                let comps = i.components(separatedBy: " - ")
                
                let startBreak = comps.first
                let endBreak = comps[1]
                
                let firstString = start + " - " + startBreak!
                let secondString = endBreak + " - " + end
                
                fullString = firstString + ", " + secondString
                
            } else {
                
                fullString = i
                
            }
            
        } else {
            
            fullString = start + " - " + end
            
        }
        
        return fullString
        
    }
    
    func createOpeningString(from weekday: Weekday) -> String {
        
        switch weekday {
        case .monday:
            return createOpeningTimes(from: monday_from, till: monday_till, withBreak: monday_break)
        case .tuesday:
            return createOpeningTimes(from: tuesday_from, till: tuesday_till, withBreak: tuesday_break)
        case .wednesday:
            return createOpeningTimes(from: wednesday_from, till: wednesday_till, withBreak: wednesday_break)
        case .thursday:
            return createOpeningTimes(from: thursday_from, till: thursday_till, withBreak: thursday_break)
        case .friday:
            return createOpeningTimes(from: friday_from, till: friday_till, withBreak: friday_break)
        case .saturday:
            return createOpeningTimes(from: saturday_from, till: saturday_till, withBreak: saturday_break)
        case .sunday:
            return ""
        }
        
    }
    
}

class Shop: NSObject, MKAnnotation, Location {
    
    var location: CLLocation
    var name: String
    
    var quater: String
    var street: String
    var houseNumber: String
    var postcode: Int
    var place: String
    var url: URL?
    var phone: URL?
    var branch: String
    var openingTimes: OpeningHours
    
    init(name: String, quater: String, street: String, houseNumber: String, postcode: Int, place: String, url: URL?, phone: URL?, location: CLLocation, branch: String, openingTimes: OpeningHours) {
        
        self.location = location
        self.name = name
        
        self.openingTimes = openingTimes
        
        self.quater = quater
        self.street = street
        self.houseNumber = houseNumber
        self.postcode = postcode
        self.place = place
        self.url = url
        self.phone = phone
        self.branch = branch
        
    }
    
    var title: String? {
        
        return self.name
        
    }
    
    var subtitle: String? {
        
        return street + " " + houseNumber
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        
        return location.coordinate
        
    }
    
}
