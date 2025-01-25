//
//  IntegrationTestCase.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation
import XCTest
import ModernNetworking
import Combine

class IntegrationTestCase: XCTestCase {
    
    public var cancellables = Set<AnyCancellable>()
    
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
