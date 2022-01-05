//
//  DefaultRubbishServiceTests.swift
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import XCTest
import UserNotifications
import Core
import ModernNetworking

@testable import RubbishFeature

final class DefaultRubbishServiceTests: XCTestCase {

    var rubbishService: DefaultRubbishService!
    var mockNotificationCenter = MockNotificationCenter()

    override func setUp() {
        super.setUp()
        
        let mockLoader = MockLoader()
        
        rubbishService = DefaultRubbishService(
            loader: mockLoader,
            notificationCenter: mockNotificationCenter
        )

    }

    override func tearDown() {
        super.tearDown()

        rubbishService = nil

    }

    func testStoreIsEnabled() {

        let isEnabled = true

        rubbishService.isEnabled = isEnabled

        XCTAssertEqual(rubbishService.isEnabled, isEnabled)

    }

    func testStoreReminderHour() {

        let reminderHour = 16

        rubbishService.reminderHour = reminderHour

        XCTAssertEqual(rubbishService.reminderHour, reminderHour)

    }

    func testStoreReminderMinute() {

        let reminderMinute = 15

        rubbishService.reminderHour = reminderMinute

        XCTAssertEqual(rubbishService.reminderHour, reminderMinute)

    }

    func testStoreReminderEnabled() {

        rubbishService.remindersEnabled = true

        XCTAssertTrue(rubbishService.remindersEnabled)

        rubbishService.remindersEnabled = false

        XCTAssertFalse(rubbishService.remindersEnabled)

    }

    func testStoreStreet() {

        rubbishService.street = "Adlerstraße"

        XCTAssertEqual(rubbishService.street, "Adlerstraße")

    }

    func testStoreResidualWaste() {

        rubbishService.residualWaste = 3

        XCTAssertEqual(rubbishService.residualWaste, 3)

    }

    func testStoreResidualWasteNil() {

        rubbishService.residualWaste = nil

        XCTAssertNil(rubbishService.residualWaste)

    }

    func testStoreOrganicWaste() {

        rubbishService.organicWaste = 3

        XCTAssertEqual(rubbishService.organicWaste, 3)

    }

    func testStoreOrganicWasteNil() {

        rubbishService.organicWaste = nil

        XCTAssertNil(rubbishService.organicWaste)

    }

    func testStorePaperWaste() {

        rubbishService.paperWaste = 3

        XCTAssertEqual(rubbishService.paperWaste, 3)

    }

    func testStorePaperWasteNil() {

        rubbishService.paperWaste = nil

        XCTAssertNil(rubbishService.paperWaste)

    }

    func testStoreYellowWaste() {

        rubbishService.yellowBag = 3

        XCTAssertEqual(rubbishService.yellowBag, 3)

    }

    func testStoreYellowWasteNil() {

        rubbishService.yellowBag = nil

        XCTAssertNil(rubbishService.yellowBag)

    }

    func testStoreGreenWaste() {

        rubbishService.greenWaste = 3

        XCTAssertEqual(rubbishService.greenWaste, 3)

    }

    func testStoreGreenWasteNil() {

        rubbishService.greenWaste = nil

        XCTAssertNil(rubbishService.greenWaste)

    }

    func testDisableReminder() {

        mockNotificationCenter.removeAllExpectation = expectation(description: "All Notification Requests should've been removed")

        rubbishService.disableReminder()

        XCTAssertEqual(rubbishService.remindersEnabled, false)
        XCTAssertEqual(rubbishService.reminderHour, 20)
        XCTAssertEqual(rubbishService.reminderMinute, 0)
        waitForExpectations(timeout: 1)

    }

    func testRegisterNotifications() {

        rubbishService.registerNotifications(at: 10, minute: 15)

        XCTAssertEqual(rubbishService.reminderHour, 10)
        XCTAssertEqual(rubbishService.reminderMinute, 15)
        XCTAssertTrue(rubbishService.remindersEnabled)

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

        rubbishService.register(street)

        XCTAssertEqual(rubbishService.street, "Teststraße")
        XCTAssertEqual(rubbishService.residualWaste, 2)
        XCTAssertEqual(rubbishService.organicWaste, 5)
        XCTAssertEqual(rubbishService.paperWaste, 4)
        XCTAssertEqual(rubbishService.yellowBag, 9)
        XCTAssertEqual(rubbishService.greenWaste, 6)

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

        rubbishService.register(street)

        let loadedStreet = rubbishService.rubbishStreet

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
