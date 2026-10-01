import UIKit
import XCTest
@testable import MMFeeds

@MainActor
final class PostsViewControllerTests: XCTestCase {
    func testUsesSelectedFeedAndPreventsOverlappingRefreshes() async throws {
        let service = ControlledPostService()
        let loaded = expectation(description: "Selected feed loaded")
        service.onLoad = { loaded.fulfill() }
        let controller = PostsViewController(
            feedID: 27,
            repository: try PostRepositoryTestFactory.make(service: service),
            onShowPost: { _ in }
        )
        await fulfillment(of: [loaded], timeout: 2)
        XCTAssertEqual(service.loadedFeedIDs, [27])

        let refresh = try refreshControl(in: controller)
        let started = expectation(description: "Refresh started")
        service.onRefresh = { started.fulfill() }
        refresh.beginRefreshing()
        try sendRefreshAction(refresh, to: controller)
        try sendRefreshAction(refresh, to: controller)
        await fulfillment(of: [started], timeout: 2)
        XCTAssertEqual(service.refreshedFeedIDs, [27])

        service.completeRefresh()
        for _ in 0..<100 where refresh.isRefreshing {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertFalse(refresh.isRefreshing)
    }

    func testControllerReleaseCancelsPendingRefresh() async throws {
        let service = ControlledPostService()
        let loaded = expectation(description: "Feed loaded")
        service.onLoad = { loaded.fulfill() }
        var controller: PostsViewController? = PostsViewController(
            feedID: 27,
            repository: try PostRepositoryTestFactory.make(service: service),
            onShowPost: { _ in }
        )
        weak let releasedController = controller
        await fulfillment(of: [loaded], timeout: 2)
        let refresh = try refreshControl(in: XCTUnwrap(controller))
        let started = expectation(description: "Refresh started")
        let cancelled = expectation(description: "Refresh cancelled")
        service.onRefresh = { started.fulfill() }
        service.onCancellation = { cancelled.fulfill() }
        try sendRefreshAction(refresh, to: XCTUnwrap(controller))
        await fulfillment(of: [started], timeout: 2)
        controller = nil
        XCTAssertNil(releasedController)
        await fulfillment(of: [cancelled], timeout: 2)
    }

    func testSynchronousReleasePreservesTaskLocalScope() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                FeedControllerTaskLocal.$marker.withValue(17) {
                    weak var releasedController: PostsViewController?
                    autoreleasepool {
                        let service = ControlledPostService()
                        var controller: PostsViewController? = PostsViewController(
                            feedID: 27,
                            repository: try! PostRepositoryTestFactory.make(service: service),
                            onShowPost: { _ in }
                        )
                        releasedController = controller
                        controller = nil
                    }
                    XCTAssertNil(releasedController)
                    XCTAssertEqual(FeedControllerTaskLocal.marker, 17)
                }
                XCTAssertEqual(FeedControllerTaskLocal.marker, 0)
                continuation.resume()
            }
        }
    }

    private func sendRefreshAction(_ refresh: UIRefreshControl, to controller: PostsViewController) throws {
        // SwiftPM tests have no UIApplication. Invoke the registered selector directly.
        let actions = try XCTUnwrap(refresh.actions(forTarget: controller, forControlEvent: .valueChanged))
        XCTAssertEqual(actions.count, 1)
        let action = try XCTUnwrap(actions.first)
        controller.perform(NSSelectorFromString(action), with: refresh)
    }

    private func refreshControl(in controller: PostsViewController) throws -> UIRefreshControl {
        let collection = try XCTUnwrap(controller.view.subviews.compactMap { $0 as? UICollectionView }.first)
        return try XCTUnwrap(collection.refreshControl)
    }
}
