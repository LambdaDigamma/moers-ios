//
//  DefaultRubbishServiceTests.swift
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import XCTest
import UserNotifications
import MMCommon

@testable import RubbishFeature

final class DefaultRubbishServiceTests: XCTestCase {

    var rubbishManager: DefaultRubbishService!
    var mockNotificationCenter = MockNotificationCenter()

    override func setUp() {
        super.setUp()
        
        rubbishManager = DefaultRubbishService(notificationCenter: mockNotificationCenter)

    }

    override func tearDown() {
        super.tearDown()

        rubbishManager = nil

    }

    func testStoreIsEnabled() {

        let isEnabled = true

        rubbishManager.isEnabled = isEnabled

        XCTAssertEqual(rubbishManager.isEnabled, isEnabled)

    }

    func testStoreReminderHour() {

        let reminderHour = 16

        rubbishManager.reminderHour = reminderHour

        XCTAssertEqual(rubbishManager.reminderHour, reminderHour)

    }

    func testStoreReminderMinute() {

        let reminderMinute = 15

        rubbishManager.reminderHour = reminderMinute

        XCTAssertEqual(rubbishManager.reminderHour, reminderMinute)

    }

    func testStoreReminderEnabled() {

        rubbishManager.remindersEnabled = true

        XCTAssertTrue(rubbishManager.remindersEnabled)

        rubbishManager.remindersEnabled = false

        XCTAssertFalse(rubbishManager.remindersEnabled)

    }

    func testStoreStreet() {

        rubbishManager.street = "Adlerstraße"

        XCTAssertEqual(rubbishManager.street, "Adlerstraße")

    }

    func testStoreResidualWaste() {

        rubbishManager.residualWaste = 3

        XCTAssertEqual(rubbishManager.residualWaste, 3)

    }

    func testStoreResidualWasteNil() {

        rubbishManager.residualWaste = nil

        XCTAssertNil(rubbishManager.residualWaste)

    }

    func testStoreOrganicWaste() {

        rubbishManager.organicWaste = 3

        XCTAssertEqual(rubbishManager.organicWaste, 3)

    }

    func testStoreOrganicWasteNil() {

        rubbishManager.organicWaste = nil

        XCTAssertNil(rubbishManager.organicWaste)

    }

    func testStorePaperWaste() {

        rubbishManager.paperWaste = 3

        XCTAssertEqual(rubbishManager.paperWaste, 3)

    }

    func testStorePaperWasteNil() {

        rubbishManager.paperWaste = nil

        XCTAssertNil(rubbishManager.paperWaste)

    }

    func testStoreYellowWaste() {

        rubbishManager.yellowBag = 3

        XCTAssertEqual(rubbishManager.yellowBag, 3)

    }

    func testStoreYellowWasteNil() {

        rubbishManager.yellowBag = nil

        XCTAssertNil(rubbishManager.yellowBag)

    }

    func testStoreGreenWaste() {

        rubbishManager.greenWaste = 3

        XCTAssertEqual(rubbishManager.greenWaste, 3)

    }

    func testStoreGreenWasteNil() {

        rubbishManager.greenWaste = nil

        XCTAssertNil(rubbishManager.greenWaste)

    }

    func testDisableReminder() {

        mockNotificationCenter.removeAllExpectation = expectation(description: "All Notification Requests should've been removed")

        rubbishManager.disableReminder()

        XCTAssertEqual(rubbishManager.remindersEnabled, false)
        XCTAssertEqual(rubbishManager.reminderHour, 20)
        XCTAssertEqual(rubbishManager.reminderMinute, 0)
        waitForExpectations(timeout: 1)

    }

    func testRegisterNotifications() {

        rubbishManager.registerNotifications(at: 10, minute: 15)

        XCTAssertEqual(rubbishManager.reminderHour, 10)
        XCTAssertEqual(rubbishManager.reminderMinute, 15)
        XCTAssertTrue(rubbishManager.remindersEnabled)

        // TODO: Mock Schedules and Check for Success

    }

    func testRegisterRubbishStreet() {

        let street = RubbishCollectionStreet(
            id: 1,
            street: "Teststraße",
            streetAddition: nil,
            residualWaste: 2,
            organicWaste: 5,
            paperWaste: 4,
            yellowBag: 9,
            greenWaste: 6,
            sweeperDay: "Montag"
        )

        rubbishManager.register(street)

        XCTAssertEqual(rubbishManager.street, "Teststraße")
        XCTAssertEqual(rubbishManager.residualWaste, 2)
        XCTAssertEqual(rubbishManager.organicWaste, 5)
        XCTAssertEqual(rubbishManager.paperWaste, 4)
        XCTAssertEqual(rubbishManager.yellowBag, 9)
        XCTAssertEqual(rubbishManager.greenWaste, 6)

    }

    func testLoadStreet() {

        let street = RubbishCollectionStreet(
            id: 1,
            street: "Teststraße",
            residualWaste: 2,
            organicWaste: 5,
            paperWaste: 4,
            yellowBag: 9,
            greenWaste: 6,
            sweeperDay: "Montag"
        )

        rubbishManager.register(street)

        let loadedStreet = rubbishManager.rubbishStreet

        XCTAssertEqual(loadedStreet, street)

    }

    static var allTests = [
        ("testStoreIsEnabled", testStoreIsEnabled),
        ("testStoreReminderHour", testStoreReminderHour),
        ("testStoreReminderMinute", testStoreReminderMinute),
        ("testStoreReminderEnabled", testStoreReminderEnabled),
        ("testStoreStreet", testStoreStreet),
        ("testStoreResidualWaste", testStoreResidualWaste),
        ("testStoreResidualWasteNil", testStoreResidualWasteNil),
        ("testStoreOrganicWaste", testStoreOrganicWaste),
        ("testStoreOrganicWasteNil", testStoreOrganicWasteNil),
        ("testStorePaperWaste", testStorePaperWaste),
        ("testStorePaperWasteNil", testStorePaperWasteNil),
        ("testStoreYellowWaste", testStoreYellowWaste),
        ("testStoreYellowWasteNil", testStoreYellowWasteNil),
        ("testStoreGreenWaste", testStoreGreenWaste),
        ("testStoreGreenWasteNil", testStoreGreenWasteNil),
        ("testDisableReminder", testDisableReminder),
        ("testRegisterNotifications", testRegisterNotifications),
        ("testRegisterRubbishStreet", testRegisterRubbishStreet),
        ("testLoadStreet", testLoadStreet),
    ]

}
