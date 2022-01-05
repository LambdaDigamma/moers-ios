//
//  DepartureMonitorLoader.swift
//  Moers
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import EFAAPI
import ModernNetworking
import Combine

class DepartureMonitorLoader: ObservableObject {
    
    private let transitService: DefaultTransitService
    
    init() {
        
        let serverEnvironment = ServerEnvironment(scheme: "https", host: "openservice.vrr.de", pathPrefix: "vrr")
        let serverEnvironmentLoader = ApplyEnvironmentLoader(environment: serverEnvironment)
        let loader = URLSessionLoader()
        transitService = DefaultTransitService(loader: (serverEnvironmentLoader --> loader)!)
        
    }
    
    func fetch() -> AnyPublisher<DepartureMonitorResponse, HTTPError> {
        
        return transitService.sendRawDepartureMonitorRequest(id: 20016032)
        
//        do {
//
//
//
//            let manager = try EFAManager(
//                efaEndpoint: "https://openservice.vrr.de/vrr/",
//                host: "openservice.vrr.de"
//            )
//
//            return manager.sendDepartureMonitorRequest(id: 20016032) // 20036298
//
//        } catch {
//            return Fail(error: error).eraseToAnyPublisher()
//        }
        
    }
    
}
