//
//  DailyEventsDisplayMode.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation

public enum DailyEventsDisplayMode: Int, CaseIterable, Identifiable, Hashable {
    
    case compact = 0
    case images = 1
    case venueGrid = 2
    
    public var id: Int {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
            case .compact:
                return String(localized: "Compact", bundle: .module)
            case .images:
                return String(localized: "Graphics", bundle: .module)
            case .venueGrid:
                return String(localized: "Venue Grid", bundle: .module)
        }
    }
    
}
