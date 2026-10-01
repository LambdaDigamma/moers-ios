//
//  FeedPostListViewModelTests.swift
//
//
//  Created by Codex on 27.06.26.
//

import Combine
import XCTest
@testable import MMFeeds

@MainActor
final class FeedPostListViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() async throws {
        cancellables.removeAll()
        try await super.tearDown()
    }

    func testItemsPublisherStartsWithPreloadedPosts() async {
        let posts = [Post.stub(withID: 42)]
        let viewModel = FeedPostListViewModel(feedID: 1, posts: posts)
        var receivedIDs: [Post.ID]?

        viewModel.itemsPublisher
            .sink { resource in
                if case let .success(posts) = resource {
                    receivedIDs = posts.map(\.id)
                }
            }
            .store(in: &cancellables)

        XCTAssertEqual(receivedIDs, [42])
    }

    func testUnusedModelIsReleasedWithoutObservers() async throws {
        var model: FeedPostListViewModel? = FeedPostListViewModel(feedID: 1, repository: try PostRepositoryTestFactory.make())
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testObservationDoesNotRetainModel() async throws {
        var model: FeedPostListViewModel? = FeedPostListViewModel(feedID: 1, repository: try PostRepositoryTestFactory.make())
        model?.setupObserver()
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testReloadResumesObservationAfterCancellation() async throws {
        let model = FeedPostListViewModel(feedID: 1, repository: try PostRepositoryTestFactory.make())
        await model.reload()
        model.cancel()
        let changed = expectation(description: "Feed received after restart")
        let observation = model.itemsPublisher
            .dropFirst()
            .sink { resource in
                if case .success(let posts) = resource, posts.map(\.id) == [42] {
                    changed.fulfill()
                }
            }
        defer { observation.cancel() }

        await model.reload()
        let result = await XCTWaiter.fulfillment(of: [changed], timeout: 2)
        XCTAssertEqual(result, .completed)
        model.cancel()
    }
}
