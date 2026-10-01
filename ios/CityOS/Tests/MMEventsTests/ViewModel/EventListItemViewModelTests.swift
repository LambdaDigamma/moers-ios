import FactoryKit
import XCTest
@testable import MMEvents

@MainActor
final class EventListItemViewModelTests: XCTestCase {
    func testFavoriteObservationDoesNotRetainRowModel() async {
        let database = MemoryDatabase.default()
        let store = FavoriteEventsStore(writer: database, reader: database)
        Container.shared.favoriteEventsStore.register { store }
        defer { Container.shared.favoriteEventsStore.reset() }
        var model: EventListItemViewModel? = EventListItemViewModel(eventID: 1, title: "Event")
        model?.setupListeners()
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }
}
