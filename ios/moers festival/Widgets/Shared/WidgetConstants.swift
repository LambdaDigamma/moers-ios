//
//  WidgetConstants.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

enum WidgetConstants {

    static let appGroupID = "group.de.okfn.niederrhein.moers-festival"
    static let favoriteEventIDsKey = "widget.favorite-event-ids"
    static let baseAPIURL = URL(string: "https://moers.app/api/v1/festival/")!
    static let eventsCacheFilename = "widget-events-cache.json"
    static let venuesCacheFilename = "widget-venues-cache.json"

    static func eventURL(for eventID: Int) -> URL {
        URL(string: "moersfestival:///events/\(eventID)")!
    }

    static var favoritesURL: URL {
        URL(string: "moersfestival:///favorites")!
    }

    static var eventsURL: URL {
        URL(string: "moersfestival:///events")!
    }

}
