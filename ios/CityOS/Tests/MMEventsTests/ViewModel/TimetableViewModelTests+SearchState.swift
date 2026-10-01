import Foundation
import XCTest
import FactoryKit
import Combine
@testable import MMEvents

extension TimetableViewModelTests {

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
        let daysCancellable = viewModel.daysPublisher
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
        let daysCancellable = viewModel.daysPublisher
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
        let daysCancellable = viewModel.daysPublisher
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

        let firstQueries = await retryStub.searchedQueries()
        XCTAssertEqual(firstQueries, ["target"])

        viewModel.retrySearch()

        await waitForSearchResults(in: viewModel, eventIDs: [1])

        XCTAssertEqual(viewModel.searchText, "target")
        XCTAssertEqual(viewModel.searchState, .loaded)
        let retriedQueries = await retryStub.searchedQueries()
        XCTAssertEqual(retriedQueries, ["target", "target"])
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
        let cancellable = viewModel.searchStatePublisher
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
}
