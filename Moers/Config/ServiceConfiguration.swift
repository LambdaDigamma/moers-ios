//
//  ServiceConfiguration.swift
//  Moers
//
//  Created by Lennart Fischer on 05.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import AppScaffold
import Resolver
import ModernNetworking
import RubbishFeature
import FuelFeature

public class ServiceConfiguration: BootstrappingProcedureStep {
    
    @LazyInjected var loader: HTTPLoader
    
    public func execute(with application: UIApplication) {
        self.setup()
    }
    
    public func setup() {
        
        let rubbishService = DefaultRubbishService(loader: loader)
        let petrolService = DefaultPetrolService(apiKey: "0dfdfad3-7385-ef47-2ff6-ec0477872677")
        
        Resolver.register { rubbishService as RubbishService }
        Resolver.register { petrolService as PetrolService }
        
    }
    
}
