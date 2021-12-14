//
//  RubbishDisplayError.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

public enum RubbishDisplayError: Error {
    
    case loadingFailed
    case noUpcomingRubbishItems
    case wasteScheduleDeactivated
    
}

extension RubbishDisplayError: LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
            case .noUpcomingRubbishItems:
                return PackageStrings.Waste.noUpcomingRubbishItems
                
            case .loadingFailed:
                return PackageStrings.Waste.loadingFailed
                
            case .wasteScheduleDeactivated:
                return PackageStrings.Waste.scheduleDeactivated
        }
        
    }
    
}
