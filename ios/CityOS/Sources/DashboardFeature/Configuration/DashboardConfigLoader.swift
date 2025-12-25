//
//  DashboardConfigLoader.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import Combine

public protocol DashboardConfigLoader {
    
    func load() -> AnyPublisher<DashboardConfig, Never>
    
    func load() throws -> DashboardConfig
    
    func save(dashboardConfig: DashboardConfig) throws
    
}

public enum DashboardConfigSaveError: LocalizedError {
    case malformedConfigURL
    case savingFailed
}
