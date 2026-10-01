import XCTest
@testable import MMFeeds

@MainActor
final class PostViewModelTests: XCTestCase {
    func testUnusedModelDoesNotObserveAndIsReleased() async throws {
        var model: PostViewModel? = PostViewModel(postID: 42, repository: try PostRepositoryTestFactory.make())
        XCTAssertTrue(model!.cancellables.isEmpty)
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testObservationDoesNotRetainModel() async throws {
        var model: PostViewModel? = PostViewModel(postID: 42, repository: try PostRepositoryTestFactory.make())
        model?.setupObserver()
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testReloadResumesObservationAfterCancellation() async throws {
        let model = PostViewModel(postID: 42, repository: try PostRepositoryTestFactory.make())
        await model.reload()
        try await waitForPost(in: model)
        model.cancel()
        model.state = .loading

        await model.reload()
        try await waitForPost(in: model)
        XCTAssertEqual(model.state.value?.id, 42)
        model.cancel()
    }

    private func waitForPost(in model: PostViewModel) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(2))
        while model.state.value?.id != 42, clock.now < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertEqual(model.state.value?.id, 42)
    }
}
