//
//  TimetableSearchViewControllerTests.swift
//
//
//  Created by Codex on 20.05.26.
//

import Combine
import UIKit
import XCTest
@testable import MMEvents

@MainActor
final class TimetableSearchViewControllerTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testSelectingSearchResultPushesDetailInsideModalAndPreservesSearchState() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
        let viewModel = TimetableViewModel(repository: repository)
        let eventDate = makeDate(year: 2030, month: 5, day: 17, hour: 12)

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.name, to: "Modal Search Target")
                .setting(\.startDate, to: eventDate)
                .setting(\.updatedAt, to: eventDate)
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.name, to: "Other Cached Event")
                .setting(\.startDate, to: eventDate.addingTimeInterval(60 * 60))
                .setting(\.updatedAt, to: eventDate)
                .toRecord()
        ])

        viewModel.beginSearch()
        viewModel.updateSearchText("modal")
        await waitForSearchResults(in: viewModel, eventIDs: [1])

        var selectedEventID: Event.ID?
        let searchViewController = TimetableSearchViewController(
            viewModel: viewModel,
            detailViewControllerFactory: { eventID in
                selectedEventID = eventID
                return UIViewController()
            }
        )
        let navigationController = UINavigationController(rootViewController: searchViewController)

        navigationController.loadViewIfNeeded()
        searchViewController.loadViewIfNeeded()
        searchViewController.viewDidAppear(false)

        searchViewController.selectEvent(1)

        let searchController = try XCTUnwrap(searchViewController.navigationItem.searchController)
        searchController.searchBar.text = ""
        searchViewController.updateSearchResults(for: searchController)

        XCTAssertEqual(selectedEventID, 1)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertTrue(viewModel.isSearchActive)
        XCTAssertEqual(viewModel.searchText, "modal")
        XCTAssertEqual(viewModel.searchResults.compactMap(\.eventID), [1])
        XCTAssertEqual(viewModel.searchState, .loaded)

        navigationController.popViewController(animated: false)
        searchViewController.viewDidAppear(false)

        let resumedSearchController = UISearchController(searchResultsController: nil)
        resumedSearchController.searchBar.text = "renamed"
        searchViewController.updateSearchResults(for: resumedSearchController)

        XCTAssertEqual(viewModel.searchText, "renamed")
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
        viewModel.$searchResults
            .map { $0.compactMap(\.eventID) }
            .filter { $0 == eventIDs }
            .first()
            .sink { _ in
                searchResultsUpdated.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [searchResultsUpdated], timeout: timeout)

        XCTAssertEqual(
            viewModel.searchResults.compactMap(\.eventID),
            eventIDs,
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

}
