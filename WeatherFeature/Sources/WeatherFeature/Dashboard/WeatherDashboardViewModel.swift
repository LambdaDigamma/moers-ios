//
//  WeatherDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import Core
import Foundation

@available(iOS 16.0, *)
public class WeatherDashboardViewModel: StandardViewModel {
    
    private let weatherService: DefaultWeatherService
    
    @Published var data: DataState<WeatherDashboardData, Error> = .loading
    
    public override init() {
        self.weatherService = DefaultWeatherService()
    }
    
    public func load() {
        
        Task {
            do {
                self.data = .success(try await weatherService.loadDashboard())
            } catch {
                self.data = .error(error)
                print(error)
            }
        }
        
    }
    
}
