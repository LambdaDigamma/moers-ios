//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    
    var body: some Widget {
        ScheduleWidget()
        WidgetsLiveActivity()
    }
    
}
