//
//  ServiceConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import UIKit
import Resolver
import Foundation
import AppScaffold
import ModernNetworking
import Core
import MMEvents

class ServiceConfiguration: BootstrappingProcedureStep {
    
    @LazyInjected var loader: HTTPLoader
    
    func execute(with application: UIApplication) {
        
        let locationService = DefaultLocationService()
        let festivalEventService = DefaultFestivalEventService(loader: loader)
        let locationEventService = DefaultLocationEventService(loader: loader)
        
        Resolver.register { locationService as LocationService }
        Resolver.register { festivalEventService as FestivalEventService }
        Resolver.register { locationEventService as LocationEventService }
        
    }
    
}
