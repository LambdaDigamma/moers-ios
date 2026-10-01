//
//  DashboardConfigDiskLoader.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import XCTest
import Combine
@testable import DashboardFeature

@MainActor
final class DashboardConfigDiskLoaderTest: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func test_load() async throws {
        
        let expectation = expectation(description: "Load dashboard config")
        let loader = DashboardConfigDiskLoader()
        
        loader
            .load()
            .sink(receiveValue: { (_: DashboardConfig) in
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 5)
        
    }
    
    func test_save() async throws {
        
        let loader = DashboardConfigDiskLoader()
        let config = DashboardConfig(updatedAt: Date())
        
        try loader.save(dashboardConfig: config)
        
    }
    
    func test_configFileURLExists() async {
        
        let loader = DashboardConfigDiskLoader()
        
        XCTAssertNotNil(loader.configURL())
        
    }
    
}
