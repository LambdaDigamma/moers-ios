//
//  WeatherDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import Core
import Foundation
import Observation

@available(iOS 16.0, *)
@MainActor
@Observable
public class WeatherDashboardViewModel: StandardViewModel {
    
    private let weatherService: DefaultWeatherService
    
    var data: DataState<WeatherDashboardData, Error> = .loading
    
    public override init() {
        self.weatherService = DefaultWeatherService()
    }
    
    public func load() async {
        do {
            self.data = .success(try await weatherService.loadDashboard())
        } catch {
            self.data = .error(error)
            print(error)
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
