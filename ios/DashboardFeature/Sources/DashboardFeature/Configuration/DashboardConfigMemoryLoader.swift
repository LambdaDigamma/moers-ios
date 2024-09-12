//
//  DashboardConfigMemoryLoader.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import Combine

/// Save and load configurations only in the memory.
/// This loader should only be used for testing reason
/// (e.g. Unit Tests or Snapshotting).
public class DashboardConfigMemoryLoader: DashboardConfigLoader {
    
    private var config: DashboardConfig
    
    public init(config: DashboardConfig = .default()) {
        self.config = config
    }
    
    /// Loads the current dashboard config from the memory
    /// synchronously. This method will never throw.
    /// - Returns: the currently stored dashboard config
    public func load() throws -> DashboardConfig {
        return config
    }
    
    /// Loads the current `DashboardConfig` from the memory or
    /// returns the default. Values will be received on the
    /// main queue.
    /// - Returns: a never-failing publisher of the dashboard config
    public func load() -> AnyPublisher<DashboardConfig, Never> {
        return Just(config)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Saves the provided `DashboardConfig` into the memory and
    /// updates the `updatedAt` property to the current date.
    /// - Parameter dashboardConfig: the dashboard config to save
    public func save(dashboardConfig: DashboardConfig) throws {
        var copiedConfig = dashboardConfig
        copiedConfig.updatedAt = Date()
        self.config = copiedConfig
    }
    
}
