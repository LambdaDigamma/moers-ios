import Foundation
import XCTest
import FactoryKit
import Combine
@testable import MMEvents

extension TimetableViewModelTests {

    func testSearchIgnoresActiveVenueFilter() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let placeStore = PlaceStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            placeStore: placeStore,
            pageStore: nil
        )

        Container.shared.eventRepository.register { repository }

        let selectedPlace = Place.stub(withID: 1)
        let otherPlace = Place(
            id: 2,
            lat: 51.451,
            lng: 6.631,
            name: "Hall 2",
            streetName: "Street",
            streetNumber: "2",
            streetAddition: nil,
            postalCode: "47441",
            postalTown: "Moers",
            countryCode: "DE",
            tags: "",
            url: nil,
            phone: nil,
            validatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        )

        try await placeStore.updateOrCreate([
            selectedPlace.toRecord(),
            otherPlace.toRecord()
        ])

        let firstDay = makeDate(year: 2030, month: 5, day: 17, hour: 12)
        let viewModel = TimetableViewModel()
        viewModel.filter = EventFilter(venueIDs: [selectedPlace.id])

        let updateApplied = expectation(description: "Search timetable update applied")
        let daysCancellable = viewModel.daysPublisher
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Visible Filtered Event")
                .setting(\.startDate, to: firstDay)
                .setting(\.placeID, to: selectedPlace.id)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.name, to: "Searchable Outside Filter")
                .setting(\.startDate, to: firstDay)
                .setting(\.placeID, to: otherPlace.id)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        viewModel.updateSearchText("outside")
        await waitForSearchResults(in: viewModel, eventIDs: [2])

        XCTAssertEqual(viewModel.days.flatMap(\.events).compactMap(\.eventID), [1])

        viewModel.updateSearchText("   ")
        await waitForSearchResults(in: viewModel, eventIDs: [2, 1])

        XCTAssertEqual(viewModel.days.flatMap(\.events).compactMap(\.eventID), [1])
    }

    func testEmptySearchQueryShowsAllCachedEvents() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )

        Container.shared.eventRepository.register { repository }

        let firstDay = makeDate(year: 2030, month: 5, day: 17, hour: 12)
        let secondDay = makeDate(year: 2030, month: 5, day: 18, hour: 12)
        let viewModel = TimetableViewModel()
        let updateApplied = expectation(description: "Empty search timetable update applied")
        let daysCancellable = viewModel.daysPublisher
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Second Searchable Event")
                .setting(\.startDate, to: secondDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.name, to: "First Searchable Event")
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        await waitForSearchResults(in: viewModel, eventIDs: [2, 1])

        XCTAssertTrue(viewModel.isSearchActive)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.hasSearchQuery)

        viewModel.updateSearchText("second")
        await waitForSearchResults(in: viewModel, eventIDs: [1])

        XCTAssertTrue(viewModel.isSearchActive)
        XCTAssertTrue(viewModel.hasSearchQuery)

        viewModel.beginSearch()
        await waitForSearchResults(in: viewModel, eventIDs: [2, 1])

        XCTAssertTrue(viewModel.isSearchActive)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.hasSearchQuery)

        viewModel.updateSearchText("   ")
        await waitForSearchResults(in: viewModel, eventIDs: [2, 1])

        XCTAssertTrue(viewModel.isSearchActive)
        XCTAssertEqual(viewModel.searchText, "   ")
        XCTAssertFalse(viewModel.hasSearchQuery)
    }

    func testCancelSearchClearsSearchWithoutMutatingFilter() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )

        Container.shared.eventRepository.register { repository }

        let expectedFilter = EventFilter(venueIDs: [99], showOnlyFavorites: true)
        let firstDay = makeDate(year: 2030, month: 5, day: 17, hour: 12)
        let viewModel = TimetableViewModel()
        viewModel.filter = expectedFilter

        let updateApplied = expectation(description: "Cancelable search timetable update applied")
        let daysCancellable = viewModel.daysPublisher
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Cancelable Search Target")
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        viewModel.updateSearchText("target")
        await waitForSearchResults(in: viewModel, eventIDs: [1])

        XCTAssertEqual(viewModel.filter, expectedFilter)

        viewModel.cancelSearch()

        XCTAssertFalse(viewModel.isSearchActive)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertEqual(viewModel.searchState, .inactive)
        XCTAssertEqual(viewModel.filter, expectedFilter)
    }

    func testSearchReusesRowViewModelForSameEvent() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )

        Container.shared.eventRepository.register { repository }

        let firstDay = makeDate(year: 2030, month: 5, day: 17, hour: 12)
        let viewModel = TimetableViewModel()
        let updateApplied = expectation(description: "Stable row search timetable update applied")
        let daysCancellable = viewModel.daysPublisher
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Reusable Search Target")
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        await waitForSearchResults(in: viewModel, eventIDs: [1])
        let initialRowID = viewModel.searchResults.first?.id

        viewModel.updateSearchText("target")
        await waitForSearchResults(in: viewModel, eventIDs: [1])

        XCTAssertEqual(viewModel.searchResults.first?.id, initialRowID)
    }

    func testNonblankSearchSectionsGroupResultsBySixAMBoundaryAndUnscheduledFinal() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )

        Container.shared.eventRepository.register { repository }

        let lateNight = makeLocalDate(year: 2030, month: 5, day: 17, hour: 23)
        let earlyMorning = makeLocalDate(year: 2030, month: 5, day: 18, hour: 5, minute: 59)
        let boundary = makeLocalDate(year: 2030, month: 5, day: 18, hour: 6)
        let viewModel = TimetableViewModel()
        let updateApplied = expectation(description: "Sectioned search timetable update applied")
        let daysCancellable = viewModel.daysPublisher
            .dropFirst()
            .filter { $0.count == 2 }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Late Night Search Event")
                .setting(\.startDate, to: lateNight)
                .setting(\.updatedAt, to: makeLocalDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.name, to: "Early Morning Search Event")
                .setting(\.startDate, to: earlyMorning)
                .setting(\.updatedAt, to: makeLocalDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 3)
                .setting(\.name, to: "Boundary Search Event")
                .setting(\.startDate, to: boundary)
                .setting(\.updatedAt, to: makeLocalDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 4)
                .setting(\.name, to: "Unscheduled Search Event")
                .setting(\.updatedAt, to: makeLocalDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        viewModel.updateSearchText("search")
        await waitForSearchResults(in: viewModel, eventIDs: [1, 2, 3, 4])
        await waitForSearchSections(in: viewModel, eventIDSections: [[1, 2], [3], [4]])

        XCTAssertEqual(
            viewModel.searchSections.compactMap(\.effectiveDay),
            [
                localStartOfDay(for: lateNight.addingTimeInterval(-EventUtilities.defaultDayOffset)),
                localStartOfDay(for: boundary.addingTimeInterval(-EventUtilities.defaultDayOffset))
            ]
        )
        XCTAssertEqual(viewModel.searchSections.last?.effectiveDay, nil)
        XCTAssertEqual(viewModel.searchSections.last?.title, EventPackageStrings.notYetScheduled)
    }

    func waitForSearchResults(
        in viewModel: TimetableViewModel,
        eventIDs: [Event.ID],
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {

        if viewModel.searchResults.compactMap(\.eventID) == eventIDs {
            return
        }

        let searchResultsUpdated = expectation(description: "Search results updated to \(eventIDs)")
        let cancellable = viewModel.searchResultsPublisher
            .map { $0.compactMap(\.eventID) }
            .filter { $0 == eventIDs }
            .first()
            .sink { _ in
                searchResultsUpdated.fulfill()
            }

        await fulfillment(of: [searchResultsUpdated], timeout: timeout)
        cancellable.cancel()

        XCTAssertEqual(
            viewModel.searchResults.compactMap(\.eventID),
            eventIDs,
            file: file,
            line: line
        )
    }

    private func waitForSearchSections(
        in viewModel: TimetableViewModel,
        eventIDSections: [[Event.ID]],
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {

        if viewModel.searchSections.map({ $0.events.compactMap(\.eventID) }) == eventIDSections {
            return
        }

        let searchSectionsUpdated = expectation(description: "Search sections updated to \(eventIDSections)")
        let cancellable = viewModel.searchSectionsPublisher
            .map { sections in
                sections.map { $0.events.compactMap(\.eventID) }
            }
            .filter { $0 == eventIDSections }
            .first()
            .sink { _ in
                searchSectionsUpdated.fulfill()
            }

        await fulfillment(of: [searchSectionsUpdated], timeout: timeout)
        cancellable.cancel()

        XCTAssertEqual(
            viewModel.searchSections.map { $0.events.compactMap(\.eventID) },
            eventIDSections,
            file: file,
            line: line
        )
    }
}
