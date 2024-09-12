//
//  DefaultWeatherService.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import CoreLocation

@available(iOS 16.0, *)
public class DefaultWeatherService: AppWeatherService {
    
    public init() {
        
        
        
    }
    
    public func loadDashboard() async throws -> WeatherDashboardData {
        
//        let location = CLLocation(latitude: 37.7749, longitude: 122.4194)
//        let weather = try await weatherService.weather(for: location)
        
        let data = WeatherDashboardData(
            temperature: 10, // weather.currentWeather.temperature.value,
            condition: "", // weather.currentWeather.condition.rawValue,
            symbolName: "" // weather.currentWeather.symbolName
        )
        
        return data
        
    }
    
}
