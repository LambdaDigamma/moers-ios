//
//  AuthClient.swift
//  
//
//  Created by Lennart Fischer on 01.08.20.
//

import Foundation
import Observation

@Observable
public class AuthClient {
    
    public var authState = State.unknown
    
    @ObservationIgnored @UserDefaultsBacked(key: "AuthToken", defaultValue: nil) public var authToken: String?
    
    public enum State {
        case unknown, signedOut, signinInProgress
        case authenthicated(authToken: String)
    }
    
    public init() {
        
        if let authToken = authToken {
            self.authState = .authenthicated(authToken: authToken)
        } else {
            self.authState = .signedOut
        }
        
    }
    
    public func logout() {
        authState = .signedOut
        authToken = nil
    }
    
}
