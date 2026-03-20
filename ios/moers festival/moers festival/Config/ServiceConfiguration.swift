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
@preconcurrency import ModernNetworking
import Core
import MMEvents
 import Factory

class ServiceConfiguration: BootstrappingProcedureStep {

    func execute(with application: UIApplication) {

        Container.shared.locationService.register {
            DefaultLocationService() as LocationService
        }

        Container.shared.festivalEventService.register {
            let loader = Container.shared.httpLoader.resolve()
            return DefaultFestivalEventService(loader: loader) as FestivalEventService
        }

        Container.shared.locationEventService.register {
            let loader = Container.shared.httpLoader.resolve()
            return DefaultLocationEventService(loader: loader) as LocationEventService
        }

    }

}
