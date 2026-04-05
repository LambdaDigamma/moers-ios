//
//  FestivalWidgetEventExtras.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetEventExtras: Codable, Hashable, Sendable {
    let openEnd: Bool?
    let scheduleDisplay: FestivalWidgetScheduleDisplayMode?
    let isPreview: Bool?

    enum CodingKeys: String, CodingKey {
        case openEnd = "open_end"
        case scheduleDisplay = "schedule_display"
        case isPreview = "is_preview"
    }
}