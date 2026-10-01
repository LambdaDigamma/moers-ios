//
//  ApplicationServerConfigurationTests.swift
//  
//
//  Created by Lennart Fischer on 08.01.21.
//

import Foundation
import XCTest
@testable import Core

nonisolated final class ApplicationServerConfigurationTests: XCTestCase {

    @MainActor
    func testRegisterURL() async {
        
        let baseURL = "https://meinmoers.lambdadigamma.com/api/v2/"
        
        ApplicationServerConfiguration.registerBaseURL(baseURL)
        
        XCTAssertEqual(ApplicationServerConfiguration.baseURL, baseURL)
        
    }
    
    @MainActor
    func testRegisterPetrolAPIKey() async {
        
        let testAPIKey = "abcde-fghij-klmno-pqrst-uvwxyz"
        
        ApplicationServerConfiguration.registerPetrolAPIKey(testAPIKey)
        
        XCTAssertEqual(ApplicationServerConfiguration.petrolAPIKey, testAPIKey)
        
    }
    
}
