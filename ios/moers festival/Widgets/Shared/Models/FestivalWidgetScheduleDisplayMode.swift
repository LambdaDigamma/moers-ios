//
//  FestivalWidgetScheduleDisplayMode.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

enum FestivalWidgetScheduleDisplayMode: String, Codable, Sendable {
    
    case hidden = "hidden"
    case date = "date"
    case dateTime = "date_time"

    var showsTimeComponent: Bool {
        self == .dateTime
    }
    
}
