//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOSApplicationExtension 17.0, *) {
            UpcomingWidget()
            FavoritesWidget()
        }
    }
}
