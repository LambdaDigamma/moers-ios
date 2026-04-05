//
//  WidgetKind.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

enum WidgetKind: String, Sendable {
    
    case upcoming = "de.okfn.niederrhein.moers-festival.widget.upcoming"
    case favorites = "de.okfn.niederrhein.moers-festival.widget.favorites"

    var title: String {
        switch self {
        case .upcoming:
            return String(localized: "Upcoming")
        case .favorites:
            return String(localized: "Favorites")
        }
    }

    var fallbackURL: URL {
        switch self {
        case .upcoming:
            return WidgetConstants.eventsURL
        case .favorites:
            return WidgetConstants.favoritesURL
        }
    }
}
