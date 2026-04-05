//
//  FestivalWidgetVenue.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetVenue: Codable, Hashable, Identifiable, Sendable {

    let id: Int
    let name: String
    let streetName: String?
    let streetNumber: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case streetName = "street_name"
        case streetNumber = "street_number"
    }

}
