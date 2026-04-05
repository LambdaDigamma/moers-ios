//
//  FestivalWidgetEvent.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetEvent: Codable, Hashable, Identifiable, Sendable {

    let id: Int
    let name: String
    let startDate: Date?
    let endDate: Date?
    let placeID: Int?
    let place: FestivalWidgetVenue?
    let extras: FestivalWidgetEventExtras?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case startDate = "start_date"
        case endDate = "end_date"
        case placeID = "place_id"
        case place
        case extras
    }

    var venueName: String {
        place?.name ?? "Venue unknown"
    }

    var showsTimeComponent: Bool {
        if let scheduleDisplay = extras?.scheduleDisplay {
            return scheduleDisplay.showsTimeComponent
        }

        return extras?.isPreview != true
    }

    var hasValidStartDate: Bool {
        startDate != nil && showsTimeComponent
    }

}