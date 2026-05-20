//
//  FestivalDeepLinkParser.swift
//  moers festival
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import Foundation

struct FestivalDeepLinkParser {
    func parse(_ url: URL) -> FestivalDeepLink? {
        guard url.scheme?.lowercased() == "moersfestival",
              url.host == nil,
              url.absoluteString.lowercased().hasPrefix("moersfestival:///") else {
            return nil
        }

        let pathComponents = url.pathComponents.compactMap { component -> String? in
            let normalizedComponent = component
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            return normalizedComponent == "/" || normalizedComponent.isEmpty ? nil : normalizedComponent
        }

        guard let firstComponent = pathComponents.first else {
            return nil
        }

        switch firstComponent {
            case "posts":
                guard pathComponents.count == 2 else {
                    return pathComponents.count == 1 ? .posts : nil
                }

                return Int(pathComponents[1]).map(FestivalDeepLink.postDetail(postID:)) ?? .posts
            case "events":
                guard pathComponents.count == 2 else {
                    return pathComponents.count == 1 ? .events : nil
                }

                return Int(pathComponents[1]).map(FestivalDeepLink.eventDetail(eventID:)) ?? .events
            case "favorites" where pathComponents.count == 1:
                return .favorites
            case "map" where pathComponents.count == 1:
                return .map
            case "venues":
                guard pathComponents.count == 2 else {
                    return pathComponents.count == 1 ? .map : nil
                }

                return Int(pathComponents[1]).map(FestivalDeepLink.venueDetail(venueID:)) ?? .map
            case "download-events" where pathComponents.count == 1:
                return .downloadEvents
            case "info" where pathComponents.count == 1:
                return .info
            case "legal" where pathComponents.count == 1:
                return .legal
            default:
                return nil
        }
    }
}
