//
//  DebugFCMTokenVisibilityTests.swift
//  moers festival Tests
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

final class DebugFCMTokenVisibilityTests: XCTestCase {

    func testDebugBuildIsVisibleWithoutReceipt() {
        XCTAssertTrue(DebugFCMTokenVisibility.isVisible(isDebugBuild: true, receiptURL: nil))
    }

    func testTestFlightSandboxReceiptIsVisible() {
        let receiptURL = URL(fileURLWithPath: "/private/var/mobile/Containers/Data/Application/AppStore/sandboxReceipt")

        XCTAssertTrue(DebugFCMTokenVisibility.isVisible(isDebugBuild: false, receiptURL: receiptURL))
    }

    func testProductionAppStoreReceiptIsHidden() {
        let receiptURL = URL(fileURLWithPath: "/private/var/mobile/Containers/Data/Application/AppStore/receipt")

        XCTAssertFalse(DebugFCMTokenVisibility.isVisible(isDebugBuild: false, receiptURL: receiptURL))
    }

    func testMissingReceiptIsHiddenOutsideDebug() {
        XCTAssertFalse(DebugFCMTokenVisibility.isVisible(isDebugBuild: false, receiptURL: nil))
    }

}
