import XCTest
@testable import MMEvents

@MainActor
final class TimetableLifetimeTests: XCTestCase {
    func testObservationDoesNotRetainModel() async {
        let database = MemoryDatabase.default()
        let repository = EventRepository(
            store: EventStore(writer: database, reader: database),
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
        var model: TimetableViewModel? = TimetableViewModel(repository: repository)
        model?.setupObserver()
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testSynchronousNestedModelReleaseKeepsTaskLocalScope() async {
        await withCheckedContinuation { continuation in
            // A UIKit callback runs on the main thread without a Swift task.
            DispatchQueue.main.async {
                XCTAssertTrue(Thread.isMainThread)
                EventDeinitializationTaskLocal.$marker.withValue(17) {
                    autoreleasepool {
                        let database = MemoryDatabase.default()
                        var service: StaticEventService? = StaticEventService(events: .success([]))
                        var repository: EventRepository? = EventRepository(
                            store: EventStore(writer: database, reader: database),
                            service: service!,
                            pageStore: nil
                        )
                        var model: TimetableViewModel? = TimetableViewModel(repository: repository!)
                        model?.setupObserver()
                        weak let releasedService = service
                        weak let releasedRepository = repository
                        weak let releasedModel = model

                        service = nil
                        repository = nil
                        model = nil

                        XCTAssertNil(releasedModel)
                        XCTAssertNil(releasedRepository)
                        XCTAssertNil(releasedService)

                        var row: EventListItemViewModel? = EventListItemViewModel(title: "Release test")
                        weak let releasedRow = row
                        row = nil
                        XCTAssertNil(releasedRow)
                    }
                    XCTAssertEqual(EventDeinitializationTaskLocal.marker, 17)
                }
                XCTAssertEqual(EventDeinitializationTaskLocal.marker, 0)
                continuation.resume()
            }
        }
    }
}
