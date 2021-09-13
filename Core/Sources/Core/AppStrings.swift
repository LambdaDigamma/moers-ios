//
//  AppStrings.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

public enum AppStrings {
    
    public static let appName = String.localized("AppName")
    
    public enum Waste {
        public static let errorMessage = String.localized("Waste.errorMessage")
        public static let loadingFailed = String.localized("Waste.loadingFailed")
        public static let noUpcomingRubbishItems = String.localized("Waste.noUpcomingRubbishItems")
    }
    
}
