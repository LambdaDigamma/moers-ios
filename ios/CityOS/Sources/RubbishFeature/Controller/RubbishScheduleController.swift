//
//  RubbishScheduleController.swift
//  
//
//  Created by Lennart Fischer on 03.02.22.
//

import Foundation
import Core

#if canImport(UIKit)
import UIKit
import Resolver
import SwiftUI

/// Hosts the `RubbishScheduleList` in a UIViewController
/// so that it can be pushed via programmatic navigation.
public class RubbishScheduleController: UIHostingController<RubbishScheduleList> {
    
    public init(rubbishService: RubbishService = Resolver.resolve()) {
        let rubbishSchedule = RubbishScheduleList(rubbishService: rubbishService)
        super.init(rootView: rubbishSchedule)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UserActivity.current = UserActivities.configureRubbishScheduleActivity()
        
    }
    
}

#endif
