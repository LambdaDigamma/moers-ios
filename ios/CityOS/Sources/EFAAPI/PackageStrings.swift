//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import Foundation
import Factory

public enum PackageStrings {
    
    public enum ObjectFilter {
        public static let noFilter = String(localized: "No filter", bundle: .module)
        public static let places = String(localized: "Place", bundle: .module)
        public static let stops = String(localized: "Stop", bundle: .module)
        public static let streets = String(localized: "Street", bundle: .module)
        public static let addresses = String(localized: "Address", bundle: .module)
        public static let crossing = String(localized: "Crossing", bundle: .module)
        public static let pointsOfInterest = String(localized: "Point of interest", bundle: .module)
        public static let postcode = String(localized: "Postcode", bundle: .module)
        public static let unknown = String(localized: "Unknown", bundle: .module)
    }
    
    public enum DepartureMonitor {
        public static let lastUpdatedAt = String(localized: "Last updated: ", bundle: .module)
    }
    
    public enum TrackChangeView {
        public static let trackChangeTitle = String(localized: "Track change", bundle: .module)
        public static func trackChangeTime(duration: String) -> String {
            return String(localized: "Current changeover time: \(duration)", bundle: .module)
        }
    }
    
    public enum FootpathChangeView {
        public static let footpathChangeTitle = String(localized: "Footpath", bundle: .module)
    }
    
}
