//
//  DeepLinkRouterSpy.swift
//  moers festival Tests
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

@testable import moers_festival

@MainActor
final class DeepLinkRouterSpy: FestivalDeepLinkRouting {
    private(set) var actions: [DeepLinkRouterSpyAction] = []

    func openNews(animated: Bool) {
        actions.append(.news)
    }

    func openPostDetail(postID: Int, animated: Bool) {
        actions.append(.postDetail(postID: postID))
    }

    func openEvents(animated: Bool) {
        actions.append(.events)
    }

    func openEventDetail(eventID: Int, animated: Bool) {
        actions.append(.eventDetail(eventID: eventID))
    }

    func openUserSchedule(animated: Bool) {
        actions.append(.favorites)
    }

    func openMap(animated: Bool) {
        actions.append(.map)
    }

    func openVenueDetail(venueID: Int, animated: Bool) {
        actions.append(.venueDetail(venueID: venueID))
    }

    func openDownloadEvents(animated: Bool) {
        actions.append(.downloadEvents)
    }

    func openInfo(animated: Bool) {
        actions.append(.info)
    }

    func openLegal(animated: Bool) {
        actions.append(.legal)
    }
}
