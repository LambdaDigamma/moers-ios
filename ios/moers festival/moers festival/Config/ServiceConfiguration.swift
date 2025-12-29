//
//  ServiceConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import UIKit
import Foundation
import AppScaffold
import ModernNetworking
import Core
import MMEvents
import Factory

class ServiceConfiguration: BootstrappingProcedureStep {
    
    @LazyInjected(\.httpLoader) var loader
    
    init() {
        
    }
    
    func execute(with application: UIApplication) {
        
        let locationService = DefaultLocationService()
        let festivalEventService = DefaultFestivalEventService(loader: loader)
        let locationEventService = DefaultLocationEventService(loader: loader)
        
        Container.shared.locationService.register {
            locationService as LocationService
        }
        
        Container.shared.festivalEventService.register {
            festivalEventService as FestivalEventService
        }
        
        Container.shared.locationEventService.register {
            locationEventService as LocationEventService
        }
        
    }
    
}
