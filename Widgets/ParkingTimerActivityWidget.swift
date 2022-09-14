//
//  ParkingTimerActivityWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 20.08.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import ActivityKit
import SwiftUI
import WidgetKit
import ParkingFeature

@available(iOSApplicationExtension 16.0, *)
struct ParkingTimerActivityWidget: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(attributesType: ParkingTimerAttributes.self) { context in
            ParkingTimerActivityView(
                attribute: context.attributes,
                state: context.state
            )
        }
    }
    
}
