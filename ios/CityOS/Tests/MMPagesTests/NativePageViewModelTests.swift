import XCTest
@testable import MMPages

@MainActor
final class NativePageViewModelTests: XCTestCase {
    func testUnusedModelDoesNotObserveAndIsReleased() async {
        var model: NativePageViewModel? = makeModel()
        weak var retainedModel = model
        XCTAssertTrue(model!.cancellables.isEmpty)
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testObservationDoesNotRetainModel() async {
        var model: NativePageViewModel? = makeModel()
        model?.setupObserver()
        weak var retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testObservationResumesWithCurrentPageAfterCancellation() async throws {
        let repository = makeRepository()
        let model = NativePageViewModel(pageID: 1, repository: repository)
        model.setupObserver()
        model.cancel()

        let page = Page.stub(withID: 1).setting(\.title, to: "Updated page")
        try await repository.store.updateOrCreate([page.toRecord()])
        let changed = expectation(description: "Current page received after restart")
        let observation = model.statePublisher.sink { state in
            if case .success(let page) = state, page.title == "Updated page" {
                changed.fulfill()
            }
        }
        defer { observation.cancel() }

        model.setupObserver()
        model.setupObserver()
        let result = await XCTWaiter.fulfillment(of: [changed], timeout: 2)
        XCTAssertEqual(result, .completed)
        model.cancel()
    }

    private func makeModel() -> NativePageViewModel {
        NativePageViewModel(pageID: 1, repository: makeRepository())
    }

    private func makeRepository() -> PageRepository {
        PageRepository(
            service: MockPageService(result: .success(Page.stub(withID: 1))),
            store: PageStore.inMemory().store
        )
    }
}
