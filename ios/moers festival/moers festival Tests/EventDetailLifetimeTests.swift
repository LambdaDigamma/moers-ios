import FactoryKit
import GRDB
import MMEvents
import MMPages
import SwiftUI
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class EventDetailLifetimeTests: XCTestCase {
    func testViewModelIsReleasedAfterReceivingAnEvent() async throws {
        let (repository, _) = try makeRepository()
        Container.shared.eventRepository.register { repository }
        defer { Container.shared.eventRepository.reset() }

        var model: EventDetailViewModel? = EventDetailViewModel(eventID: 10)
        try await repository.store.deleteAllAndInsert([Event(id: 10, name: "Lifetime fixture").toRecord()])
        for _ in 0..<100 where model?.event?.id != 10 {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertEqual(model?.event?.id, 10)

        weak let releasedModel = model
        model = nil

        XCTAssertNil(releasedModel, "The event observation must not retain its view model.")
        releasedModel?.cancel()
    }

    func testModelIsReleasedInASynchronousMainQueueCallback() async throws {
        let (repository, _) = try makeRepository()
        Container.shared.eventRepository.register { repository }
        defer { Container.shared.eventRepository.reset() }

        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                XCTAssertTrue(withUnsafeCurrentTask { $0 == nil })
                var model: EventDetailViewModel? = EventDetailViewModel(eventID: 10)
                weak let releasedModel = model
                model = nil

                XCTAssertNil(releasedModel)
                releasedModel?.cancel()
                continuation.resume()
            }
        }
    }

    func testLoadedDetailIsReleasedAfterNavigationRemoval() async throws {
        let (repository, favorites) = try makeRepository()
        Container.shared.eventRepository.register { repository }
        Container.shared.favoriteEventsStore.register { favorites }
        defer {
            Container.shared.eventRepository.reset()
            Container.shared.favoriteEventsStore.reset()
        }

        weak var releasedController: ModernEventDetailViewController?
        autoreleasepool {
            let navigationController = UINavigationController(rootViewController: UIViewController())
            let controller = ModernEventDetailViewController(eventID: 10)
            releasedController = controller
            controller.loadViewIfNeeded()
            navigationController.pushViewController(controller, animated: false)
            navigationController.popViewController(animated: false)
        }

        for _ in 0..<100 where releasedController != nil {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertNil(releasedController, "The hosted view and stored subscriptions must not retain the detail.")
    }

    func testHostedDetailObservesUpdatesAfterDisappearingAndReturning() async throws {
        let (repository, _) = try makeRepository()
        Container.shared.eventRepository.register { repository }
        defer { Container.shared.eventRepository.reset() }

        try await repository.store.deleteAllAndInsert([Event(id: 10, name: "Before navigation").toRecord()])
        let model = EventDetailViewModel(eventID: 10)
        let appeared = expectation(description: "Detail appeared")
        let disappeared = expectation(description: "Detail disappeared")
        let reappeared = expectation(description: "Detail returned")
        var appearanceCount = 0
        let hosted = UIHostingController(rootView: ModernEventView(
            viewModel: model,
            actionTransmitter: ActionTransmitter()
        ).onAppear {
            appearanceCount += 1
            if appearanceCount == 1 {
                appeared.fulfill()
            } else if appearanceCount == 2 {
                reappeared.fulfill()
            }
        }.onDisappear {
            if appearanceCount == 1 {
                disappeared.fulfill()
            }
        })
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = hosted
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKey()
        }

        await fulfillment(of: [appeared], timeout: 2)
        for _ in 0..<100 where model.event?.name != "Before navigation" {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertEqual(model.event?.name, "Before navigation")

        window.rootViewController = UIViewController()
        await fulfillment(of: [disappeared], timeout: 2)
        window.rootViewController = hosted
        await fulfillment(of: [reappeared], timeout: 2)

        try await repository.store.deleteAllAndInsert([Event(id: 10, name: "After navigation").toRecord()])
        for _ in 0..<100 where model.event?.name != "After navigation" {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertEqual(model.event?.name, "After navigation", "Returning to the detail must retain its event observation.")
    }

    func testDetailDoesNotOwnItsCoordinator() async throws {
        let (repository, _) = try makeRepository()
        Container.shared.eventRepository.register { repository }
        defer { Container.shared.eventRepository.reset() }

        let detail = ModernEventDetailViewController(eventID: 10)
        var coordinator: SharedCoordinator? = SharedCoordinator()
        weak let releasedCoordinator = coordinator
        detail.coordinator = coordinator

        coordinator = nil

        XCTAssertNil(releasedCoordinator, "The coordinator owns navigation and must not be owned by a detail.")
        detail.coordinator = nil
    }

    private func makeRepository() throws -> (EventRepository, FavoriteEventsStore) {
        let queue = try DatabaseQueue()
        let database = try AppDatabase(queue)
        let repository = EventRepository(
            store: EventStore(writer: database.dbWriter, reader: database.reader),
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
        return (repository, FavoriteEventsStore(writer: queue, reader: queue))
    }
}
