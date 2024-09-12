//
//  NetworkingConfiguration.swift
//  Moers
//
//  Created by Lennart Fischer on 11.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit
import AppScaffold
import ModernNetworking
import Resolver
import OSLog

public let subsystem = Bundle.main.bundleIdentifier ?? "de.okfn.niederrhein.Moers"

extension ServerEnvironment {
    
    public static let local = ServerEnvironment(host: "mein-moers.localhost", pathPrefix: "/api/v1")
//    public static let development = ServerEnvironment(host: "development.moers.app", pathPrefix: "/api/v1")
    public static let staging = ServerEnvironment(host: "staging.moers.app", pathPrefix: "/api/v1")
    public static let production = ServerEnvironment(host: "moers.app", pathPrefix: "/api/v1")
    
}

class NetworkingConfiguration: BootstrappingProcedureStep {
    
    private let logger = Logger(.coreAppConfig)
    
    public init() {
        
    }
    
    func execute(with application: UIApplication) {
        
        setupEnvironmentAndLoader()
        
    }
    
    func executeInExtension() {
        
        setupEnvironmentAndLoader()
        
    }
    
    @discardableResult
    public func setupEnvironmentAndLoader() -> HTTPLoader {
        
        let environment = loadServerEnvironment()
        
        logger.log(level: .info, "Using Environment \(environment.host) with prefix \(environment.pathPrefix)")
        
        guard let loader = setupLoaderChain(with: environment) else {
            fatalError("Networking Stack could not be setup.")
        }
        
        Resolver.register { loader as HTTPLoader }
        
        return loader
        
    }
    
    private func loadServerEnvironment() -> ServerEnvironment {
        
        var settingsEnvironment = "production"
        
        #if DEBUG
        settingsEnvironment = "local"
        settingsEnvironment = UserDefaults.standard.string(forKey: "environment") ?? "production"
        #endif
        
        let environment: ServerEnvironment
        
        switch settingsEnvironment {
            case "custom":
                
                var customUrl = UserDefaults.standard.string(forKey: "customUrlTextField") ?? ""
                
                if customUrl.contains("http://") {
                    customUrl = customUrl.replacingOccurrences(of: "http://", with: "")
                    environment = ServerEnvironment(scheme: "http", host: customUrl, pathPrefix: "/api/v1")
                } else if customUrl.contains("https://") {
                    customUrl = customUrl.replacingOccurrences(of: "https://", with: "")
                    environment = ServerEnvironment(scheme: "https", host: customUrl, pathPrefix: "/api/v1")
                } else {
                    environment = ServerEnvironment(scheme: "https", host: customUrl, pathPrefix: "/api/v1")
                }
                
            case "production":
                environment = .production
                
            case "staging":
                environment = .staging
                
//            case "development":
//                environment = .development
                
            case "local":
                environment = .local
                
            default:
                environment = .production
        }
        
        return environment
        
    }
    
    private func setupLoaderChain(with environment: ServerEnvironment) -> HTTPLoader? {
        
        let modifier = ModifyRequestLoader { request in
            
            let preferredLocale = Bundle.main.preferredLocalizations.first ?? "en"
            
            var copy = request
            
            copy.headers.updateValue("application/json; charset=utf-8", forKey: "Accept")
            copy.headers.updateValue(preferredLocale, forKey: "Accept-Language")
            
//            let resolver = Resolver()
//            let tokenStore: TokenStore = Resolver.resolve() as TokenStore
            
//            if let token = tokenStore.getToken() {
//                copy.headers.updateValue("Bearer \(token)", forKey: "Authorization")
//            }
            
            if copy.path.hasPrefix("/") == false {
                copy.path = "/api/v1" + copy.path
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
        return resetGuard --> applyEnvironment --> modifier --> printLoader --> sessionLoader
        #else
        return resetGuard --> applyEnvironment --> modifier --> sessionLoader
        #endif
        
    }
    
}
