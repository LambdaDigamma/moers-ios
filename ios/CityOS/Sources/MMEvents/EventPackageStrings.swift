//
//  EventPackageStrings.swift
//  
//
//  Created by Lennart Fischer on 25.05.22.
//

import Foundation

public enum EventPackageStrings {
    
    public static let locationNotKnown = String(localized: "Site soon known", bundle: .module)
    
    public static let locationHeader = String(localized: "Location", bundle: .module)
    public static let ticketsHeader = String(localized: "Tickets", bundle: .module)
    public static let artistsHeader = String(localized: "Artists", bundle: .module)
    public static let startHeader = String(localized: "Start", bundle: .module)
    public static let endHeader = String(localized: "End", bundle: .module)
    
    public static let unknown = String(localized: "unknown", bundle: .module)
    
    public static let notYetScheduled = String(localized: "No time yet", bundle: .module)
    
    public static let timetable = String(localized: "Timetable", bundle: .module)
    
    public enum Download {
        
        public static let downloadHeader = String(localized: "Download data", bundle: .module)
        public static let downloadFooter = String(localized: "Downloading the entire timetable may result in higher data usage.", bundle: .module)
        
        public static let downloadContent = String(localized: "Download content", bundle: .module)
        public static let downloadMedia = String(localized: "Download media", bundle: .module)
        
        public static let downloadTimetable = String(localized: "Download timetable", bundle: .module)
        
        public static let eventOverview = String(localized: "Overview", bundle: .module)
        
        public static let content = String(localized: "Content", bundle: .module)
        public static let media = String(localized: "Images", bundle: .module)
        
    }
    
}
