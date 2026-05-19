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
import Core
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
        Container.shared.favoriteEventsStore.reset()
        Container.shared.currentDateProvider.reset()
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

    func testInitialSelectedDateUsesInjectedCurrentDate() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )

        Container.shared.eventRepository.register { repository }

        let firstDay = makeDate(year: 2026, month: 5, day: 22, hour: 12)
        let secondDay = makeDate(year: 2026, month: 5, day: 23, hour: 12)
        let simulatedNow = makeDate(year: 2026, month: 5, day: 23, hour: 18)
        let currentDateProvider = MMEventsTestCurrentDateProvider(now: simulatedNow)
        let expectedSelectedDay = Calendar.autoupdatingCurrent.startOfDay(for: secondDay)

        let viewModel = TimetableViewModel(currentDateProvider: currentDateProvider)
        let updateApplied = expectation(description: "Timetable update applied")
        let daysCancellable = viewModel.$days
            .filter { $0.count == 2 }
            .first()
            .sink { _ in updateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2026, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.startDate, to: secondDay)
                .setting(\.updatedAt, to: makeDate(year: 2026, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [updateApplied], timeout: 1)
        daysCancellable.cancel()

        XCTAssertEqual(viewModel.selectedDate, expectedSelectedDay)
    }

    func testRegisteredFavoriteEventsStoreDoesNotRecreateRowsOrEmitDaysOnSameDayTimeTicks() async throws {

        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let favoriteEventsStore = FavoriteEventsStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
        let currentDateProvider = MMEventsTestCurrentDateProvider(
            now: makeDate(year: 2026, month: 5, day: 22, hour: 10)
        )

        Container.shared.eventRepository.register { repository }
        Container.shared.favoriteEventsStore.register { favoriteEventsStore }
        Container.shared.currentDateProvider.register { currentDateProvider }

        let event = Event.stub(withID: 1)
            .setting(\.startDate, to: makeDate(year: 2026, month: 5, day: 22, hour: 12))
            .setting(\.updatedAt, to: makeDate(year: 2026, month: 5, day: 1, hour: 12))

        try await store.deleteAllAndInsert([event.toRecord()])
        try await favoriteEventsStore.createFavoriteEvent(eventID: event.id)

        let viewModel = TimetableViewModel(currentDateProvider: currentDateProvider)
        let initialDaysEmission = expectation(description: "Initial timetable days emitted")
        let initialDaysCancellable = viewModel
            .$days
            .filter { days in
                days.count == 1 && days.first?.events.map(\.eventID) == [event.id]
            }
            .first()
            .sink { _ in initialDaysEmission.fulfill() }

        await fulfillment(of: [initialDaysEmission], timeout: 1)
        initialDaysCancellable.cancel()

        let initialDates = viewModel.dates
        let initialRowIdentifiers = viewModel.days
            .flatMap(\.events)
            .map { ObjectIdentifier($0) }
        let unexpectedDaysEmission = expectation(description: "Same-day tick should not emit timetable days again")
        unexpectedDaysEmission.isInverted = true
        let daysCancellable = viewModel
            .$days
            .dropFirst()
            .sink { _ in unexpectedDaysEmission.fulfill() }

        currentDateProvider.now = makeDate(year: 2026, month: 5, day: 22, hour: 18)

        await fulfillment(of: [unexpectedDaysEmission], timeout: 0.2)
        daysCancellable.cancel()

        let currentRowIdentifiers = viewModel.days
            .flatMap(\.events)
            .map { ObjectIdentifier($0) }

        XCTAssertEqual(viewModel.dates, initialDates)
        XCTAssertEqual(currentRowIdentifiers, initialRowIdentifiers)
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
