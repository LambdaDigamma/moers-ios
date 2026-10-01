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

@MainActor
final class DefaultRubbishServiceTests: XCTestCase {

    private var defaultsSuiteName: String!
    var rubbishService: DefaultRubbishService!
    var mockNotificationCenter = MockNotificationCenter()

    override func setUp() async throws {
        try await super.setUp()
        
        defaultsSuiteName = UUID().uuidString
        let mockLoader = MockLoader()
        
        rubbishService = DefaultRubbishService(
            loader: mockLoader,
            notificationCenter: mockNotificationCenter,
            userDefaults: UserDefaults(suiteName: defaultsSuiteName)!
        )

    }

    override func tearDown() async throws {
        try await super.tearDown()

        rubbishService = nil
        UserDefaults.standard.removePersistentDomain(forName: defaultsSuiteName)
        defaultsSuiteName = nil

    }

    func testStoreIsEnabled() async {

        let isEnabled = true

        rubbishService.isEnabled = isEnabled

        XCTAssertEqual(rubbishService.isEnabled, isEnabled)

    }

    func testStoreReminderHour() async {

        let reminderHour = 16

        rubbishService.reminderHour = reminderHour

        XCTAssertEqual(rubbishService.reminderHour, reminderHour)

    }

    func testStoreReminderMinute() async {

        let reminderMinute = 15

        rubbishService.reminderHour = reminderMinute

        XCTAssertEqual(rubbishService.reminderHour, reminderMinute)

    }

    func testStoreReminderEnabled() async {

        rubbishService.remindersEnabled = true

        XCTAssertTrue(rubbishService.remindersEnabled)

        rubbishService.remindersEnabled = false

        XCTAssertFalse(rubbishService.remindersEnabled)

    }

    func testStoreStreet() async {

        rubbishService.street = "Musterstraße"

        XCTAssertEqual(rubbishService.street, "Musterstraße")

    }

    func testStoreResidualWaste() async {

        rubbishService.residualWaste = 3

        XCTAssertEqual(rubbishService.residualWaste, 3)

    }

    func testStoreResidualWasteNil() async {

        rubbishService.residualWaste = nil

        XCTAssertNil(rubbishService.residualWaste)

    }

    func testStoreOrganicWaste() async {

        rubbishService.organicWaste = 3

        XCTAssertEqual(rubbishService.organicWaste, 3)

    }

    func testStoreOrganicWasteNil() async {

        rubbishService.organicWaste = nil

        XCTAssertNil(rubbishService.organicWaste)

    }

    func testStorePaperWaste() async {

        rubbishService.paperWaste = 3

        XCTAssertEqual(rubbishService.paperWaste, 3)

    }

    func testStorePaperWasteNil() async {

        rubbishService.paperWaste = nil

        XCTAssertNil(rubbishService.paperWaste)

    }

    func testStoreYellowWaste() async {

        rubbishService.yellowBag = 3

        XCTAssertEqual(rubbishService.yellowBag, 3)

    }

    func testStoreYellowWasteNil() async {

        rubbishService.yellowBag = nil

        XCTAssertNil(rubbishService.yellowBag)

    }

    func testStoreGreenWaste() async {

        rubbishService.greenWaste = 3

        XCTAssertEqual(rubbishService.greenWaste, 3)

    }

    func testStoreGreenWasteNil() async {

        rubbishService.greenWaste = nil

        XCTAssertNil(rubbishService.greenWaste)

    }

    func testDisableReminder() async {

        mockNotificationCenter.getPendingRequestsExpectation = expectation(description: "Pending Notification Requests should be loaded")
        mockNotificationCenter.removePendingExpectation = expectation(description: "Reminder Notification Requests should be removed")

        rubbishService.disableReminder()

        XCTAssertEqual(rubbishService.remindersEnabled, false)
        XCTAssertEqual(rubbishService.reminderHour, 20)
        XCTAssertEqual(rubbishService.reminderMinute, 0)
        let result = await XCTWaiter.fulfillment(of: [
            mockNotificationCenter.getPendingRequestsExpectation!,
            mockNotificationCenter.removePendingExpectation!
        ], timeout: 2)
        XCTAssertEqual(result, .completed)

    }

    func testInvalidateRubbishReminderNotificationsRemovesOnlyRubbishReminderRequests() async {

        let rubbishReminderIdentifier = "RubbishReminder-1-1-2026-paper"
        let parkingReminderIdentifier = "ParkingReminder-1"

        mockNotificationCenter.pendingNotifications = [
            makeNotificationRequest(identifier: rubbishReminderIdentifier),
            makeNotificationRequest(identifier: parkingReminderIdentifier)
        ]
        mockNotificationCenter.getPendingRequestsExpectation = expectation(description: "Pending Notification Requests should be loaded")
        mockNotificationCenter.removePendingExpectation = expectation(description: "Reminder Notification Requests should be removed")

        rubbishService.invalidateRubbishReminderNotifications()

        let result = await XCTWaiter.fulfillment(of: [
            mockNotificationCenter.getPendingRequestsExpectation!,
            mockNotificationCenter.removePendingExpectation!
        ], timeout: 2)
        XCTAssertEqual(result, .completed)
        XCTAssertEqual(mockNotificationCenter.removedIdentifiers, [rubbishReminderIdentifier])
        XCTAssertEqual(mockNotificationCenter.pendingNotifications.map(\.identifier), [parkingReminderIdentifier])

    }

    func testRegisterNotifications() async {

        rubbishService.registerNotifications(at: 10, minute: 15)

        XCTAssertEqual(rubbishService.reminderHour, 10)
        XCTAssertEqual(rubbishService.reminderMinute, 15)
        XCTAssertTrue(rubbishService.remindersEnabled)
        
    }

    func testRegisterRubbishStreet() async {

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

    func testLoadStreet() async {

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


}

private func makeNotificationRequest(identifier: String) -> UNNotificationRequest {
    UNNotificationRequest(
        identifier: identifier,
        content: UNMutableNotificationContent(),
        trigger: nil
    )
}
