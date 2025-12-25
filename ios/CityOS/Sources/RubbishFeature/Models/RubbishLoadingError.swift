//
//  RubbishDashboardError.swift
//  
//
//  Created by Lennart Fischer on 04.01.22.
//

import Foundation

public enum RubbishLoadingError: LocalizedError {
    
    case deactivated
    case noStreetConfigured
    case noYearData
    case internalError(Error)
    
    public var errorDescription: String? {
        return self.text
    }
    
    public var title: String {
        switch self {
            case .deactivated:
                return PackageStrings.RubbishDashboardError.Deactivated.title
            case .noStreetConfigured:
                return PackageStrings.RubbishDashboardError.NotConfigured.title
            case .noYearData:
                return PackageStrings.RubbishDashboardError.NoYearData.title
            case .internalError:
                return PackageStrings.RubbishDashboardError.InternalError.title
        }
    }
    
    public var text: String {
        switch self {
            case .deactivated:
                return PackageStrings.RubbishDashboardError.Deactivated.text
            case .noStreetConfigured:
                return PackageStrings.RubbishDashboardError.NotConfigured.text
            case .noYearData:
                return PackageStrings.RubbishDashboardError.NoYearData.text
            case .internalError(let error):
                return error.localizedDescription
        }
    }
    
}
