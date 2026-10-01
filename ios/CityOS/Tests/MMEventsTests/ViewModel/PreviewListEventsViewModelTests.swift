import Observation
import XCTest
@testable import MMEvents

@MainActor
final class PreviewListEventsViewModelTests: XCTestCase {
    func testUnusedModelDoesNotObserveAndIsReleased() async {
        var model: PreviewListEventsViewModel? = PreviewListEventsViewModel(repository: repository())
        weak var retainedModel = model
        XCTAssertTrue(model!.cancellables.isEmpty)
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testObservationDoesNotRetainModel() async {
        var model: PreviewListEventsViewModel? = PreviewListEventsViewModel(repository: repository())
        model?.setupObserver()
        weak var retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testObservationResumesWithCurrentEventsAfterCancellation() async throws {
        let repository = repository()
        let model = PreviewListEventsViewModel(repository: repository)
        model.setupObserver()
        model.cancel()

        try await repository.store.insert(Event(id: 1, name: "Updated event"))
        let changed = expectation(description: "Current events received after restart")
        withObservationTracking {
            _ = model.events
        } onChange: {
            changed.fulfill()
        }

        model.setupObserver()
        model.setupObserver()
        let result = await XCTWaiter.fulfillment(of: [changed], timeout: 2)
        XCTAssertEqual(result, .completed)
        XCTAssertEqual(model.events.map(\.eventID), [1])
        XCTAssertEqual(model.events.map(\.title), ["Updated event"])
        model.cancel()
    }

    private func repository() -> EventRepository {
        let writer = MemoryDatabase.default()
        return EventRepository(
            store: EventStore(writer: writer, reader: writer),
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
    }
}
