//
//  SceneDelegateConnectionUserActivityRoutingTests.swift
//  moers festival Tests
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

@MainActor
final class SceneDelegateConnectionUserActivityRoutingTests: XCTestCase {
    func testConnectionWebActivityRoutesThroughApplicationController() {
        let sceneDelegate = SceneDelegate()
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)

        XCTAssertTrue(sceneDelegate.shouldRouteConnectionUserActivityThroughApplicationController(userActivity))
    }

    func testConnectionNonWebActivityRoutesThroughTabBarController() {
        let sceneDelegate = SceneDelegate()
        let userActivity = NSUserActivity(activityType: "de.okfn.niederrhein.moers-festival.openEvent")

        XCTAssertFalse(sceneDelegate.shouldRouteConnectionUserActivityThroughApplicationController(userActivity))
    }
}
