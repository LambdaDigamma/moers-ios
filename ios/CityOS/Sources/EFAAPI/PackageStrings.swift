//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import Foundation
import Factory

internal extension String {
    
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle.module, value: "", comment: "")
    }
    
}

public enum PackageStrings {
    
    public enum ObjectFilter {
        public static let noFilter = String.localized("ObjectFilter.noFilter")
        public static let places = String.localized("ObjectFilter.places")
        public static let stops = String.localized("ObjectFilter.stops")
        public static let streets = String.localized("ObjectFilter.streets")
        public static let addresses = String.localized("ObjectFilter.addresses")
        public static let crossing = String.localized("ObjectFilter.crossing")
        public static let pointsOfInterest = String.localized("ObjectFilter.pointsOfInterest")
        public static let postcode = String.localized("ObjectFilter.postcode")
        public static let unknown = String.localized("ObjectFilter.unknown")
    }
    
    public enum DepartureMonitor {
        public static let lastUpdatedAt = String.localized("DepartureMonitor.lastUpdatedAt")
    }
    
    public enum TrackChangeView {
        public static let trackChangeTitle = String.localized("TrackChangeView.trackChangeTitle")
        public static func trackChangeTime(duration: String) -> String {
            return String.localizedStringWithFormat(String.localized("TrackChangeView.trackChangeTime"), duration)
        }
    }
    
    public enum FootpathChangeView {
        public static let footpathChangeTitle = String.localized("TrackChangeView.footpathChangeTitle")
    }
    
}
