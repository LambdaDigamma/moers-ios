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
import FactoryKit

class ServiceConfiguration: BootstrappingProcedureStep {

    func execute(with application: UIApplication) {

        Container.shared.locationService.register {
            DefaultLocationService() as LocationService
        }

        Container.shared.festivalEventService.register {
            let client = Container.shared.httpClient.resolve()
            return DefaultFestivalEventService(client: client) as FestivalEventService
        }

        Container.shared.locationEventService.register {
            let client = Container.shared.httpClient.resolve()
            return DefaultLocationEventService(client: client) as LocationEventService
        }

    }

}
