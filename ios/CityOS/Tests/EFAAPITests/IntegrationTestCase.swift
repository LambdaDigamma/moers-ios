//
//  IntegrationTestCase.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation
import XCTest
import ModernNetworking

@MainActor
class IntegrationTestCase: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        guard ProcessInfo.processInfo.environment["RUN_EFA_INTEGRATION_TESTS"] == "1" else {
            throw XCTSkip("Set RUN_EFA_INTEGRATION_TESTS=1 to run live transit API tests.")
        }
    }
    
    func defaultLoader() -> HTTPLoader {
        
        let environment = ServerEnvironment(scheme: "https", host: "openservice.vrr.de", pathPrefix: "/vrr")
        
        let resetGuard = ResetGuardLoader()
        let applyEnvironment = ApplyEnvironmentLoader(environment: environment)
        let session = URLSession(configuration: .default)
        let sessionLoader = URLSessionLoader(session)
        let printLoader = PrintLoader()
        
        return (resetGuard --> applyEnvironment --> printLoader --> sessionLoader)!
        
    }
    
}
