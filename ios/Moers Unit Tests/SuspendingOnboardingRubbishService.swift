import RubbishFeature
import XCTest

@MainActor
final class SuspendingOnboardingRubbishService: RubbishService {
    let rubbishStreet: RubbishCollectionStreet? = nil
    var isEnabled = true
    var remindersEnabled = false
    let reminderHour: Int? = nil
    let reminderMinute: Int? = nil
    private let started: XCTestExpectation
    private let cancelled: XCTestExpectation

    init(started: XCTestExpectation, cancelled: XCTestExpectation) {
        self.started = started
        self.cancelled = cancelled
    }

    func loadRubbishCollectionStreets() async throws -> [RubbishCollectionStreet] {
        started.fulfill()
        do {
            try await Task.sleep(nanoseconds: 60_000_000_000)
        } catch {
            cancelled.fulfill()
            throw error
        }
        return []
    }

    func register(_ street: RubbishCollectionStreet) {}
    func loadRubbishPickupItems(for street: RubbishCollectionStreet) async throws -> [RubbishPickupItem] { [] }
    func registerNotifications(at hour: Int, minute: Int) {}
    func invalidateRubbishReminderNotifications() {}
    func disableReminder() {}
    func disableStreet() {}
}
