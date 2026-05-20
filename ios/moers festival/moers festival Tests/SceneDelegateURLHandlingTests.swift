//
//  SceneDelegateURLHandlingTests.swift
//  moers festival Tests
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

@MainActor
final class SceneDelegateURLHandlingTests: XCTestCase {
    func testHandleURLsStopsAfterFirstHandledURL() {
        let unhandledURL = URL(string: "moersfestival:///unknown")!
        let handledURL = URL(string: "moersfestival:///events")!
        let skippedURL = URL(string: "moersfestival:///posts")!
        let coordinator = DeeplinkCoordinatorProtocolSpy(urlsToHandle: [handledURL])
        let sceneDelegate = SceneDelegate()
        sceneDelegate.deeplinkCoordinator = coordinator

        let handled = sceneDelegate.handleURLs([unhandledURL, handledURL, skippedURL])

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.handledURLs, [unhandledURL, handledURL])
    }

    func testHandleURLsAttemptsAllURLsWhenNoneAreHandled() {
        let firstURL = URL(string: "moersfestival:///unknown")!
        let secondURL = URL(string: "moersfestival:///news")!
        let coordinator = DeeplinkCoordinatorProtocolSpy()
        let sceneDelegate = SceneDelegate()
        sceneDelegate.deeplinkCoordinator = coordinator

        let handled = sceneDelegate.handleURLs([firstURL, secondURL])

        XCTAssertFalse(handled)
        XCTAssertEqual(coordinator.handledURLs, [firstURL, secondURL])
    }
}
