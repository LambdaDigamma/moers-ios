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
import NewsWidgets

@main
struct WidgetsBundle: WidgetBundle {
    
    var body: some Widget {
        NewsWidgets()
//        DepartureMonitorWidget()
        RubbishWidget()
    }
    
}
