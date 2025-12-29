//
//  NetworkingConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import ModernNetworking

extension ServerEnvironment {
    
    public static let local = ServerEnvironment(host: "moers-festival.localhost", pathPrefix: "/api/v1")
    public static let staging = ServerEnvironment(host: "beta.moers-festival.de", pathPrefix: "/api/v1")
    public static let production = ServerEnvironment(host: "app.moers-festival.de", pathPrefix: "/api/v1")
    
}

class NetworkingConfiguration: BootstrappingProcedureStep {
    
    public private(set) static var environment: ServerEnvironment!
    
    func execute(with application: UIApplication) {
        
        ApplicationServerConfiguration.isMoersFestivalModeEnabled = true
        
        let environment = loadServerEnvironment()
        
        print("Recognized environment with host: \(environment.host)")
        
        guard let loader = setupLoaderChain(with: environment) else {
            fatalError("Networking stack could not be setup.")
        }
        
        Container.shared.httpLoader.register {
            loader
        }
        
    }
    
    private func loadServerEnvironment() -> ServerEnvironment {
        
        var settingsEnvironment = "production"
        
        #if DEBUG
        settingsEnvironment = UserDefaults.standard.string(forKey: "environment") ?? "production"
        #endif
        
        let environment: ServerEnvironment
        
        switch settingsEnvironment {
            case "custom":
                
                var customUrl = UserDefaults.standard.string(forKey: "customUrlTextField") ?? ""
                
                if customUrl.contains("http://") {
                    customUrl = customUrl.replacingOccurrences(of: "http://", with: "")
                    environment = ServerEnvironment(scheme: "http", host: customUrl)
                } else if customUrl.contains("https://") {
                    customUrl = customUrl.replacingOccurrences(of: "https://", with: "")
                    environment = ServerEnvironment(scheme: "https", host: customUrl)
                } else {
                    environment = ServerEnvironment(scheme: "https", host: customUrl)
                }
                
            case "production":
                environment = .production
                
            case "staging":
                environment = .staging
                
            case "development":
                environment = .development
                
            case "local":
                environment = .local
                
            default:
                environment = .production
        }
        
        NetworkingConfiguration.environment = environment
        
        return environment
        
    }
    
    private func setupLoaderChain(with environment: ServerEnvironment) -> HTTPLoader? {
        
        let modifier = ModifyRequestLoader { request in
            
            var copy = request
            
            copy.headers.updateValue("application/json; charset=utf-8", forKey: "Accept")
            
//            if case let .authenthicated(authToken) = authClient.authState {
//                copy.headers.updateValue("Bearer \(authToken)", forKey: "Authorization")
//            }
            
            if copy.path.hasPrefix("/") == false {
                copy.path = "/api/v1/" + copy.path
            }
            
            return copy
            
        }
        
        let resetGuard = ResetGuardLoader()
        let applyEnvironment = ApplyEnvironmentLoader(environment: environment)
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        let sessionLoader = URLSessionLoader(session)
        let printLoader = PrintLoader()
        
        #if DEBUG
        return (resetGuard --> applyEnvironment --> modifier --> printLoader --> sessionLoader)
        #else
        return (resetGuard --> applyEnvironment --> modifier --> sessionLoader)
        #endif
        
    }
    
}
