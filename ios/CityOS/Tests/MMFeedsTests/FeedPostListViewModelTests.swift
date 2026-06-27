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

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testItemsPublisherStartsWithPreloadedPosts() {
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

}
