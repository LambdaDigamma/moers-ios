import Foundation
import XCTest
@testable import Core

nonisolated final class BroadcastListViewModelTests: XCTestCase {

    @MainActor
    func testLoadAppliesBroadcastsPublishedFromBackgroundQueue() async throws {
        let broadcast = RadioBroadcast(
            id: 1,
            uid: "background-broadcast",
            title: "Bürgerfunk Moers"
        )
        let viewModel = BroadcastListViewModel(
            service: BackgroundRadioService(broadcasts: [broadcast])
        )

        viewModel.load()

        try await waitUntil {
            viewModel.broadcasts.count == 1
        }

        XCTAssertEqual(viewModel.upcomingBroadcasts.map(\.id), [broadcast.id])
        XCTAssertEqual(viewModel.broadcasts.map(\.id), [broadcast.id])
        XCTAssertEqual(viewModel.viewModels.map(\.title), [broadcast.title])
    }

    @MainActor
    private func waitUntil(
        timeout: Duration = .seconds(1),
        predicate: @MainActor @escaping () -> Bool
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)

        while clock.now < deadline {
            if predicate() {
                return
            }

            try await Task.sleep(for: .milliseconds(10))
        }

        XCTFail("Timed out waiting for condition.")
    }

}
