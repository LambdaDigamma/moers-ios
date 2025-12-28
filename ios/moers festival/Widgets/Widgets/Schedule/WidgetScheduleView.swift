//
//  WidgetScheduleView.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct WidgetScheduleView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        
        switch widgetFamily {
            case .systemSmall:
                ScheduleSmall(data: .init(items: []))
            case .systemMedium:
                ScheduleMedium(data: .init(items: []))
            default:
                EmptyView()
        }
        
    }
}
