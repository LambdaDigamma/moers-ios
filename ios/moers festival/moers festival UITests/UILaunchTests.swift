//
//  UILaunchTests.swift
//  moers festival UITests
//
//  Created by Lennart Fischer on 13.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import XCTest

class UILaunchTests: XCTestCase {

    @MainActor
    func testShowsOnboardingWithFreshDefaults() {
        let app = XCUIApplication()
        app.launchArguments = [
            "-wasLaunchedBefore", "NO",
            "-UserDidCompleteSetup", "NO",
            "-showedDownload", "YES"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["Discover the moers festival"].waitForExistence(timeout: 5))
    }

    func testLaunchPerformance() {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
    }

}
