//
//  WidgetBundle.swift
//  Moers
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct WidgetsBundle: WidgetBundle {
    
    var body: some Widget {
        if #available(iOSApplicationExtension 16.0, *) {
            return iOS16Widgets()
        } else if #available(iOSApplicationExtension 15.0, *) {
            return iOS15Widgets()
        }
    }
    
    @WidgetBundleBuilder
    func iOS15Widgets() -> some Widget {
        NewsWidgets()
//        DepartureMonitorWidget()
        RubbishWidget()
    }
    
    @available(iOSApplicationExtension 16.0, *)
    @WidgetBundleBuilder
    func iOS16Widgets() -> some Widget {
        NewsWidgets()
//        DepartureMonitorWidget()
        RubbishWidget()
        ParkingTimerActivityWidget()
    }
    
}
