//
//  WeatherDashboardData.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import Foundation

public struct WeatherDashboardData: Equatable {
    
    public let temperature: Double
    public let condition: String
    public let symbolName: String
    
    public init(temperature: Double, condition: String, symbolName: String) {
        self.temperature = temperature
        self.condition = condition
        self.symbolName = symbolName
    }
    
}
