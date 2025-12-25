//
//  TripDateTimeType.swift
//  
//
//  Created by Lennart Fischer on 08.04.22.
//

import Foundation

public enum TripDateTimeType: String, CaseIterable {
    
    case departure = "dep"
    case arrival = "arr"
    
    public var name: String {
        switch self {
            case .departure:
                return "Abfahrtszeit"
            case .arrival:
                return "Ankunftszeit"
        }
    }
    
}
