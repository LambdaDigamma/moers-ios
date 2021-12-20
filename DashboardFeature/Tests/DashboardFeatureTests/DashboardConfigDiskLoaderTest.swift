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

final class DashboardConfigDiskLoaderTest: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func test_load() throws {
        
        let expectation = expectation(description: "Load dashboard config")
        let loader = DashboardConfigDiskLoader()
        
        loader
            .load()
            .sink(receiveValue: { (config: DashboardConfig) in
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
    }
    
    func test_save() throws {
        
        let loader = DashboardConfigDiskLoader()
        let config = DashboardConfig(updatedAt: Date())
        
        try loader.save(dashboardConfig: config)
        
    }
    
    func test_configFileURLExists() {
        
        let loader = DashboardConfigDiskLoader()
        
        XCTAssertNotNil(loader.configURL())
        
    }
    
}
