import FactoryKit
import GRDB
import Events
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class VenueDetailLifetimeTests: XCTestCase {
    func testViewModelIsReleasedAfterReceivingVenueEvents() async throws {
        let repository = try await makeRepository()
        Container.shared.eventRepository.register { repository }
        defer { Container.shared.eventRepository.reset() }

        var model: VenueDetailViewModel? = VenueDetailViewModel(placeID: 1)
        try await repository.store.deleteAllAndInsert([
            Event(id: 10, name: "Venue lifetime fixture", placeID: 1).toRecord()
        ])
        for _ in 0..<100 where model?.events.first?.eventID != 10 {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertEqual(model?.events.compactMap(\.eventID), [10])

        weak let releasedModel = model
        model = nil

        XCTAssertNil(releasedModel, "The venue event observation must not retain its view model.")
        releasedModel?.cancellables.removeAll()
    }

    func testLoadedVenueIsReleasedAfterNavigationRemoval() async throws {
        let repository = try await makeRepository()
        Container.shared.eventRepository.register { repository }
        defer { Container.shared.eventRepository.reset() }

        weak var releasedController: VenueDetailController?
        autoreleasepool {
            let navigationController = UINavigationController(rootViewController: UIViewController())
            let controller = VenueDetailController(placeID: 1)
            releasedController = controller
            controller.loadViewIfNeeded()
            navigationController.pushViewController(controller, animated: false)
            navigationController.popViewController(animated: false)
        }

        for _ in 0..<100 where releasedController != nil {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertNil(releasedController, "The hosted event action and URL subscription must not retain the venue.")
    }

    func testModelIsReleasedInASynchronousMainQueueCallback() async throws {
        let repository = try await makeRepository()
        Container.shared.eventRepository.register { repository }
        defer { Container.shared.eventRepository.reset() }

        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                XCTAssertTrue(withUnsafeCurrentTask { $0 == nil })
                var model: VenueDetailViewModel? = VenueDetailViewModel(placeID: 1)
                weak let releasedModel = model
                model = nil

                XCTAssertNil(releasedModel)
                releasedModel?.cancellables.removeAll()
                continuation.resume()
            }
        }
    }

    private func makeRepository() async throws -> EventRepository {
        let queue = try DatabaseQueue()
        let database = try AppDatabase(queue)
        let placeStore = PlaceStore(writer: queue, reader: queue)
        try await placeStore.insert(Place.stub(withID: 1).toRecord())
        return EventRepository(
            store: EventStore(writer: database.dbWriter, reader: database.reader),
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
    }
}
