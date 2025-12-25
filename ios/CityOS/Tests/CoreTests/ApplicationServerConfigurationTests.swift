//
//  ApplicationServerConfigurationTests.swift
//  
//
//  Created by Lennart Fischer on 08.01.21.
//

import Foundation
import XCTest
@testable import Core

final class ApplicationServerConfigurationTests: XCTestCase {
    
    func testRegisterURL() {
        
        let baseURL = "https://meinmoers.lambdadigamma.com/api/v2/"
        
        ApplicationServerConfiguration.registerBaseURL(baseURL)
        
        XCTAssertEqual(ApplicationServerConfiguration.baseURL, baseURL)
        
    }
    
    func testRegisterPetrolAPIKey() {
        
        let testAPIKey = "abcde-fghij-klmno-pqrst-uvwxyz"
        
        ApplicationServerConfiguration.registerPetrolAPIKey(testAPIKey)
        
        XCTAssertEqual(ApplicationServerConfiguration.petrolAPIKey, testAPIKey)
        
    }
    
    static var allTests = [
        ("testRegisterURL", testRegisterURL),
        ("testRegisterPetrolAPIKey", testRegisterPetrolAPIKey),
    ]
    
}
