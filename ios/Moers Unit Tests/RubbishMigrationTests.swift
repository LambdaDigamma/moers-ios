import AppScaffold
import RubbishFeature
import XCTest
@testable import Moers

@MainActor
final class RubbishMigrationTests: XCTestCase {
    func testMigrationRetainsTheReminderMinuteAndUsesDefaults() async throws {
        for (hour, minute, expectedHour, expectedMinute) in [
            (Int?(18), Int?(37), 18, 37),
            (Int?(18), nil, 18, 0),
            (nil, nil, 20, 0)
        ] {
            let service = StaticRubbishService(isEnabled: false, remindersEnabled: true, reminderHour: hour, reminderMinute: minute)
            let controller = AppTabBarController(firstLaunch: FirstLaunch(getWasLaunchedBefore: { true }, setWasLaunchedBefore: { _ in }))
            controller.rubbishService = service
            let streets = try await service.loadRubbishCollectionStreets()
            let street = try XCTUnwrap(streets.first)
            controller.registerRubbishMigrationStreet(street)
            XCTAssertEqual(service.rubbishStreet, street)
            XCTAssertTrue(service.isEnabled)
            XCTAssertEqual(service.reminderHour, expectedHour)
            XCTAssertEqual(service.reminderMinute, expectedMinute)
        }
    }

    func testMigrationDoesNotEnableDisabledReminders() async throws {
        let service = StaticRubbishService(isEnabled: false, remindersEnabled: false)
        let controller = AppTabBarController(firstLaunch: FirstLaunch(getWasLaunchedBefore: { true }, setWasLaunchedBefore: { _ in }))
        controller.rubbishService = service
        let streets = try await service.loadRubbishCollectionStreets()
        let street = try XCTUnwrap(streets.first)
        controller.registerRubbishMigrationStreet(street)
        XCTAssertFalse(service.remindersEnabled)
        XCTAssertNil(service.reminderHour)
        XCTAssertNil(service.reminderMinute)
    }
}
