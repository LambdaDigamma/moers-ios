//
//  DebugTimeConfiguration.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import AppScaffold
import Core
import Factory
import UIKit

final class DebugTimeConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        let controller = DebugTimeController()
        
        Container.shared.currentDateProvider.register {
            controller
        }
    }
    
}

#endif
