//
//  TimetableViewModelTests.swift
//
//
//  Created by Codex on 16.03.26.
//

import Foundation
import XCTest
import Factory
import Combine
@testable import MMEvents

@MainActor
final class TimetableViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "timetableFilter")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "timetableFilter")
        Container.shared.eventRepository.reset()
        super.tearDown()
    }

    func testSelectionIsPreservedAcrossEventUpdates() async throws {

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
        let selectedDay = Calendar.autoupdatingCurrent.startOfDay(for: secondDay)

        let viewModel = TimetableViewModel()
        let secondUpdateApplied = expectation(description: "Second timetable update applied")
        var updateCount = 0
        let daysCancellable = viewModel
            .$days
            .dropFirst()
            .sink { _ in
                updateCount += 1
                if updateCount == 2 {
                    secondUpdateApplied.fulfill()
                }
            }

        let firstUpdateApplied = expectation(description: "First timetable update applied")
        let firstUpdateCancellable = viewModel.$days
            .filter { $0.count == 2 }
            .first()
            .sink { _ in firstUpdateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.startDate, to: secondDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [firstUpdateApplied], timeout: 1)
        firstUpdateCancellable.cancel()

        viewModel.selectDate(selectedDay)

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 2, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.startDate, to: secondDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 2, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [secondUpdateApplied], timeout: 1)
        daysCancellable.cancel()

        XCTAssertEqual(viewModel.selectedDate, selectedDay)
    }

    func testSelectedDateNormalizesToAvailableDayWhenAssignedWithTimeComponent() async throws {

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
        let selectedDayWithTime = makeDate(year: 2030, month: 5, day: 18, hour: 19)
        let normalizedSelectedDay = Calendar.autoupdatingCurrent.startOfDay(for: secondDay)

        let viewModel = TimetableViewModel()
        let updateApplied = expectation(description: "Timetable update applied")
        let daysCancellable = viewModel.$days
            .filter { $0.count == 2 }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.startDate, to: secondDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.selectDate(selectedDayWithTime)

        XCTAssertEqual(viewModel.selectedDate, normalizedSelectedDay)
        XCTAssertEqual(viewModel.dates.last, normalizedSelectedDay)
    }

    func testVenueFilterKeepsMatchingEventsWhenPlacesAreAvailable() async throws {

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
        let secondDay = makeDate(year: 2030, month: 5, day: 18, hour: 12)

        let viewModel = TimetableViewModel()
        viewModel.filter = EventFilter(venueIDs: [selectedPlace.id])

        let updateApplied = expectation(description: "Filtered timetable update applied")
        let daysCancellable = viewModel.$days
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.startDate, to: firstDay)
                .setting(\.placeID, to: selectedPlace.id)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.startDate, to: secondDay)
                .setting(\.placeID, to: otherPlace.id)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        let visibleEventIDs = viewModel.days
            .flatMap(\.events)
            .compactMap(\.eventID)

        XCTAssertEqual(viewModel.days.count, 2)
        XCTAssertEqual(visibleEventIDs, [1])
        XCTAssertEqual(viewModel.days.first?.events.first?.location, selectedPlace.name)
        XCTAssertTrue(viewModel.days.last?.events.isEmpty == true)
    }

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
        let daysCancellable = viewModel.$days
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
        let daysCancellable = viewModel.$days
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
        let daysCancellable = viewModel.$days
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

    func testCancelSearchPreventsStaleResultsFromRepopulating() async throws {

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
        let updateApplied = expectation(description: "Stale search timetable update applied")
        let daysCancellable = viewModel.$days
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Stale Search Target")
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        viewModel.updateSearchText("stale")
        viewModel.cancelSearch()
        viewModel.updateSearchText("stale")

        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.isSearchActive)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertEqual(viewModel.searchState, .inactive)
    }

    func testSearchKeepsLoadingSeparateFromNoResults() async throws {

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
        let updateApplied = expectation(description: "Loading search timetable update applied")
        let daysCancellable = viewModel.$days
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Only Cached Event")
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        viewModel.updateSearchText("missing")

        XCTAssertEqual(viewModel.searchState, .loading)
        XCTAssertFalse(viewModel.searchState == .loaded && viewModel.searchResults.isEmpty)

        await waitForSearchResults(in: viewModel, eventIDs: [])

        XCTAssertEqual(viewModel.searchState, .loaded)
    }

    func testSearchFailureSetsFailedStateInsteadOfEmptyLoadedResults() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )

        let firstDay = makeDate(year: 2030, month: 5, day: 17, hour: 12)
        let viewModel = TimetableViewModel(
            repository: repository,
            searchEvents: { _, _ in
                throw NSError(domain: "TimetableSearchTests", code: 1)
            }
        )
        let updateApplied = expectation(description: "Failing search timetable update applied")
        let daysCancellable = viewModel.$days
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Failing Search Target")
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        viewModel.beginSearch()
        viewModel.updateSearchText("target")

        XCTAssertEqual(viewModel.searchState, .loading)

        await waitForSearchState(in: viewModel, state: .failed)

        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.searchState == .loaded && viewModel.searchResults.isEmpty)
    }

    func testRetrySearchRunsCurrentQueryAfterFailure() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
        let retryStub = RetrySearchStub(
            event: Event.stub(withID: 1)
                .setting(\.name, to: "Retry Search Target")
                .setting(\.startDate, to: makeDate(year: 2030, month: 5, day: 17, hour: 12))
        )
        let viewModel = TimetableViewModel(
            repository: repository,
            searchEvents: { _, query in
                try await retryStub.search(query: query)
            }
        )

        viewModel.beginSearch()
        viewModel.updateSearchText("target")

        await waitForSearchState(in: viewModel, state: .failed)

        XCTAssertEqual(await retryStub.searchedQueries(), ["target"])

        viewModel.retrySearch()

        await waitForSearchResults(in: viewModel, eventIDs: [1])

        XCTAssertEqual(viewModel.searchText, "target")
        XCTAssertEqual(viewModel.searchState, .loaded)
        XCTAssertEqual(await retryStub.searchedQueries(), ["target", "target"])
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
        let daysCancellable = viewModel.$days
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
        let daysCancellable = viewModel.$days
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

    private func waitForSearchResults(
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
        let cancellable = viewModel.$searchResults
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

    private func waitForSearchState(
        in viewModel: TimetableViewModel,
        state: TimetableSearchState,
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {

        if viewModel.searchState == state {
            return
        }

        let searchStateUpdated = expectation(description: "Search state updated to \(state)")
        let cancellable = viewModel.$searchState
            .filter { $0 == state }
            .first()
            .sink { _ in
                searchStateUpdated.fulfill()
            }

        await fulfillment(of: [searchStateUpdated], timeout: timeout)
        cancellable.cancel()

        XCTAssertEqual(
            viewModel.searchState,
            state,
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
        let cancellable = viewModel.$searchSections
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

    private func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {

        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour

        return components.date ?? Date()
    }

    private func makeLocalDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int = 0
    ) -> Date {

        let calendar = Calendar.autoupdatingCurrent
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute

        return components.date ?? Date()
    }

    private func localStartOfDay(for date: Date) -> Date {
        Calendar.autoupdatingCurrent.startOfDay(for: date)
    }

}
