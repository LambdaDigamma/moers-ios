//
//  DeeplinkCoordinator.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation

protocol DeeplinkCoordinatorProtocol {

    @discardableResult
    func handleURL(_ url: URL) -> Bool
}

final class DeeplinkCoordinator {

    private weak var router: FestivalDeepLinkRouting?
    private let parser: FestivalDeepLinkParser

    init(router: FestivalDeepLinkRouting?, parser: FestivalDeepLinkParser = FestivalDeepLinkParser()) {
        self.router = router
        self.parser = parser
    }
}

extension DeeplinkCoordinator: DeeplinkCoordinatorProtocol {

    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        guard let deepLink = parser.parse(url) else {
            return false
        }

        route(deepLink)
        return true
    }

    private func route(_ deepLink: FestivalDeepLink) {
        switch deepLink {
            case .posts:
                router?.openNews(animated: false)
            case .postDetail(let postID):
                router?.openPostDetail(postID: postID, animated: false)
            case .events:
                router?.openEvents(animated: false)
            case .eventDetail(let eventID):
                router?.openEventDetail(eventID: eventID, animated: false)
            case .favorites:
                router?.openUserSchedule(animated: false)
            case .map:
                router?.openMap(animated: false)
            case .venueDetail(let venueID):
                router?.openVenueDetail(venueID: venueID, animated: false)
            case .downloadEvents:
                router?.openDownloadEvents(animated: false)
            case .info:
                router?.openInfo(animated: false)
            case .legal:
                router?.openLegal(animated: false)
        }
    }
}
