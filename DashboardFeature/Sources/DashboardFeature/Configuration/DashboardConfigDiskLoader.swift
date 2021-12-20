//
//  DashboardConfigDiskLoader.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import Combine
import OSLog

/// Save and load configurations into or from the disk.
/// Configurations are stored in a plist file in the user's documents
/// directory. This loader should be used by default.
public class DashboardConfigDiskLoader: DashboardConfigLoader {
    
    private let configFileName = "DashboardConfiguration.plist"
    private let logger = Logger(.default)
    
    public init() {
        
    }
    
    /// Loads the current `DashboardConfig` from the disk asynchronously
    /// or returns the default. Values will be received on the main queue.
    /// - Returns: a never-failing publisher of the dashboard configuration
    public func load() -> AnyPublisher<DashboardConfig, Never> {
        
        return Deferred {
            return Future<DashboardConfig, Error> { promise in
                
                do {
                    let config: DashboardConfig = try self.load()
                    promise(.success(config))
                } catch {
                    promise(.failure(error))
                }
                
            }
        }
        .replaceError(with: DashboardConfig.default())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    /// Loads the current dashboard configuration from the disk
    /// synchronously. Throws a `LoaderError` if retrieving
    /// the configuration fails.
    /// - Returns: the currently stored dashboard configuration
    public func load() throws -> DashboardConfig {
        
        let decoder = PropertyListDecoder()
        
        guard let configURL = self.configURL() else {
            throw LoaderError.malformedConfigURL
        }
        
        guard let data = try? Data(contentsOf: configURL),
              let config = try? decoder.decode(DashboardConfig.self, from: data)
        else {
            throw LoaderError.decodingFailed
        }
        
        return config
        
    }
    
    /// Touches the `updatedAt` property to the current date and
    /// saves the provided `DashboardConfig` to disk.
    /// - Parameter dashboardConfig: the dashboard configuration to save
    public func save(dashboardConfig: DashboardConfig) throws {
        
        let encoder = PropertyListEncoder()
        
        guard let configURL = configURL() else {
            throw DashboardConfigSaveError.malformedConfigURL
        }
        
        var copiedConfig = dashboardConfig
        copiedConfig.updatedAt = Date()
        
        do {
            
            let data = try encoder.encode(copiedConfig)
            
            if FileManager.default.fileExists(atPath: configURL.path) {
                try data.write(to: configURL)
            } else {
                FileManager.default.createFile(atPath: configURL.path, contents: data, attributes: nil)
            }
            
        } catch {
            logger.error("Saving failed: \(error.localizedDescription, privacy: .public)")
            throw DashboardConfigSaveError.savingFailed
        }
        
    }
    
    /// Get the dashboard configuration url.
    /// The dashboard configuration is being saved in user's documents
    /// directory and the file is called `DashboardConfiguration.plist`.
    /// - Returns: the configuration file url or nil if there is no documents directory
    internal func configURL() -> URL? {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsFolder?.appendingPathComponent(configFileName)
    }
    
    internal enum LoaderError: Error {
        case malformedConfigURL
        case decodingFailed
    }
    
}
