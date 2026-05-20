//
//  DeeplinkCoordinatorTests.swift
//  moers festival Tests
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

@MainActor
final class DeeplinkCoordinatorTests: XCTestCase {
    func testDispatchesPostDetail() {
        let router = DeepLinkRouterSpy()
        let coordinator = DeeplinkCoordinator(router: router)

        let handled = coordinator.handleURL(URL(string: "moersfestival:///posts/42")!)

        XCTAssertTrue(handled)
        XCTAssertEqual(router.actions, [.postDetail(postID: 42)])
    }

    func testDispatchesVenueDetail() {
        let router = DeepLinkRouterSpy()
        let coordinator = DeeplinkCoordinator(router: router)

        let handled = coordinator.handleURL(URL(string: "moersfestival:///venues/7")!)

        XCTAssertTrue(handled)
        XCTAssertEqual(router.actions, [.venueDetail(venueID: 7)])
    }

    func testDoesNotDispatchInvalidLinks() {
        let router = DeepLinkRouterSpy()
        let coordinator = DeeplinkCoordinator(router: router)

        let handled = coordinator.handleURL(URL(string: "moersfestival://events/12")!)

        XCTAssertFalse(handled)
        XCTAssertTrue(router.actions.isEmpty)
    }
}
