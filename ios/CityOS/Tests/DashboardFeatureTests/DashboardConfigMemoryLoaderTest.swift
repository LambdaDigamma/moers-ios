//
//  DashboardConfigMemoryLoaderTest.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import XCTest
import DashboardFeature

@MainActor
final class DashboardConfigMemoryLoaderTest: XCTestCase {
    
    func test_load() async throws {
        
        let loader = DashboardConfigMemoryLoader()
        let config: DashboardConfig = try loader.load()
        
        XCTAssertNotNil(config.updatedAt)
        
    }
    
    func test_save() async throws {
        
        let loader = DashboardConfigMemoryLoader()
        let config = DashboardConfig(updatedAt: Date(timeIntervalSinceNow: -60 * 60))
        
        try loader.save(dashboardConfig: config)
        let loadedConfig: DashboardConfig = try loader.load()
        
        XCTAssertNotNil(loadedConfig)
        
    }
    
}
