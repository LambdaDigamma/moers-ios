//
//  WidgetScheduleData.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation

public struct WidgetScheduleItem: Equatable, Identifiable {
    
    public var id: UUID = .init()
    
    public let name: String
    public let startDate: Date
    public let place: String
    
}

public struct WidgetScheduleData: Equatable {
    
    var items: [WidgetScheduleItem]
    
    static var staticContent = [
        WidgetScheduleItem(
            name: "Editrix (US)",
            startDate: Date(timeIntervalSinceNow: 60 * 7),
            place: "enni.eventhalle"
        ),
        WidgetScheduleItem(
            name: "SAPAT (DE, SE, UK)",
            startDate: Date(timeIntervalSinceNow: 60 * 70),
            place: "AmViehTheater"
        ),
        WidgetScheduleItem(
            name: "FYEAR (CA)",
            startDate: Date(timeIntervalSinceNow: 60 * 150),
            place: "enni.eventhalle"
        ),
        WidgetScheduleItem(
            name: "Lukas Ligeti spricht: … à propos de mon père (AT)",
            startDate: Date(timeIntervalSinceNow: 60 * 150),
            place: "enni.eventhalle"
        )
    ]
    
}
