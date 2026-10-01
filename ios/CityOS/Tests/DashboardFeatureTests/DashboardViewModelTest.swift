import Core
import Observation
import XCTest
@testable import DashboardFeature

@MainActor
final class DashboardViewModelTest: XCTestCase {
    func testNotificationSubscriptionsDoNotRetainDiscardedModel() async {
        var model: DashboardViewModel? = DashboardViewModel(loader: DashboardConfigDiskLoader())
        weak var retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testBackgroundNotificationUpdatesDashboardOnMainActor() async throws {
        let loader = DashboardConfigMemoryLoader()
        let item = EmptyDashboardConfiguration()
        try loader.save(dashboardConfig: DashboardConfig(items: [item]))
        let model = DashboardViewModel(loader: loader)
        let changed = expectation(description: "Dashboard updated after background notification")
        withObservationTracking {
            _ = model.displayables
        } onChange: {
            changed.fulfill()
        }

        let notificationName = Notification.Name.updateDashboard
        await Task.detached {
            NotificationCenter.default.post(name: notificationName, object: nil)
        }.value
        let result = await XCTWaiter.fulfillment(of: [changed], timeout: 2)
        XCTAssertEqual(result, .completed)
        XCTAssertEqual(model.displayables.map(\.id), [item.id])
    }

}
