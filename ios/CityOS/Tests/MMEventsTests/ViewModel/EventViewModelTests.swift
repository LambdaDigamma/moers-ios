//
//  EventViewModelTests.swift
//  
//
//  Created by Lennart Fischer on 07.01.21.
//

import Foundation

import XCTest
import ModernNetworking
import Combine
import Core
@testable import MMEvents

extension Locale {
    
    static func isNotEnglish() -> Bool {
        return !Locale.current.identifier.contains("en-")
    }
    
}

@MainActor
final class EventViewModelTests: XCTestCase {
    
    override func setUp() async throws {
        
        ApplicationServerConfiguration.isMoersFestivalModeEnabled = true
        
        
        
    }
    
    override func tearDown() async throws {
        
    }
    
    func testMFActiveOnlyStart() async {
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -5 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertTrue(viewModel.isActive)
        
    }
    
    func testMFNotActiveOnlyStart() async {
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -65 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertFalse(viewModel.isActive)
        
    }
    
    func testMFActiveStartEnd() async {
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -65 * 60))
            .setting(\Event.endDate, to: Date(timeIntervalSinceNow: 5 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertTrue(viewModel.isActive)
        
    }
    
    func testMFNotActiveStartEnd() async {
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -65 * 60))
            .setting(\Event.endDate, to: Date(timeIntervalSinceNow: -5 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertFalse(viewModel.isActive)
        
    }
    
    func testMFSubtitleStartAndEndSoon() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: 5 * 60))
            .setting(\Event.endDate, to: Date(timeIntervalSinceNow: 35 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.subtitle, "Site soon known · in 5min")
        
    }
    
    func testMFSubtitleStartSoon() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: 45 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        print(viewModel.isActive, "isActive")
        
        
        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.subtitle, "Site soon known · in 45min")
        
    }
    
    func testMFSubtitleStartAndEnd() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date.from("03.04.2019 10:00", withFormat: "dd.MM.yyyy HH:mm"))
            .setting(\Event.endDate, to: Date.from("03.04.2019 12:00", withFormat: "dd.MM.yyyy HH:mm"))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertEqual(viewModel.subtitle, "Site soon known · We, 03.04. 10:00 - 12:00")
        
    }
    
    func testMFSubtitleStart() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date.from("03.04.2019 10:00", withFormat: "dd.MM.yyyy HH:mm"))
        
        let viewModel = EventViewModel(event: event)
        
        print(viewModel.subtitle)
        
        XCTAssertEqual(viewModel.subtitle, "Site soon known · We, 03.04. 10:00")
        
    }
    
    func testMFSubtitleStartTimeUnknown() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date.from("03.04.2019 00:00", withFormat: "dd.MM.yyyy HH:mm"))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertEqual(viewModel.subtitle, "Site soon known · We, 03.04.")
        
    }
    
    func testMFSubtitleActiveStart() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -5 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertEqual(viewModel.subtitle, "Site soon known · live now")
        
    }
    
    func testMFSubtitleActiveStartEnd() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -5 * 60))
            .setting(\Event.endDate, to: Date(timeIntervalSinceNow: 5 * 60))
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertEqual(viewModel.subtitle, "Site soon known · live now")
        
    }
    
    func testMFDetailSubtitleFreeTicket() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let extras = EventExtras
            .stub(withID: 1)
            .setting(\EventExtras.needsFestivalTicket, to: false)
            .setting(\EventExtras.isFree, to: true)
            .setting(\EventExtras.visitWithExtraTicket, to: false)
            .setting(\EventExtras.isMovingAct, to: false)
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -5 * 60))
            .setting(\Event.endDate, to: Date(timeIntervalSinceNow: 5 * 60))
            .setting(\Event.extras, to: extras)
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertEqual(viewModel.detailSubtitle, "Site soon known · live now · free")
        
    }
    
    func testMFDetailSubtitleFestivalTicket() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let extras = EventExtras
            .stub(withID: 1)
            .setting(\EventExtras.needsFestivalTicket, to: true)
            .setting(\EventExtras.isFree, to: false)
            .setting(\EventExtras.visitWithExtraTicket, to: false)
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -5 * 60))
            .setting(\Event.endDate, to: Date(timeIntervalSinceNow: 5 * 60))
            .setting(\Event.extras, to: extras)
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertEqual(viewModel.detailSubtitle, "Site soon known · live now · festival/day ticket required")
        
    }
    
    func testMFDetailSubtitleExtraTicket() async throws {
        
        try XCTSkipIf(Locale.isNotEnglish(), "Skipping due to locale.")
        
        let extras = EventExtras
            .stub(withID: 1)
            .setting(\EventExtras.needsFestivalTicket, to: false)
            .setting(\EventExtras.isFree, to: false)
            .setting(\EventExtras.visitWithExtraTicket, to: true)
        
        let event = Event
            .stub(withID: 1)
            .setting(\Event.startDate, to: Date(timeIntervalSinceNow: -5 * 60))
            .setting(\Event.endDate, to: Date(timeIntervalSinceNow: 5 * 60))
            .setting(\Event.extras, to: extras)
        
        let viewModel = EventViewModel(event: event)
        
        XCTAssertEqual(viewModel.detailSubtitle, "Site soon known · live now · festival/day ticket or Mörzz-Ticket required (*)")
        
    }
    
    func testMFLocationMovingAct() async {
        //
        //        let extras = EventExtras
        //            .stub(withID: 1)
        //            .setting(\EventExtras.isMovingAct, to: true)
        //
        //        let event = Event
        //            .stub(withID: 1)
        //            .setting(\Event.startDate, to: Date.from("03.04.2019 10:00", withFormat: "dd.MM.yyyy HH:mm"))
        //            .setting(\Event.endDate, to: Date.from("03.04.2019 12:00", withFormat: "dd.MM.yyyy HH:mm"))
        //            .setting(\Event.extras, to: extras)
        //
        //        let viewModel = EventViewModel(event: event)
        //
        //        XCTAssertEqual(viewModel.subtitle, "Moving Act · We, 03.04. 10:00 - 12:00")
        //
    }

    func testLocationRepresentationPrefersLocationOverStreet() async {
        let extras = EventExtras(location: "Haus der Demokratiegeschichte", street: "Kastell 5")
        let event = Event
            .stub(withID: 1)
            .setting(\Event.extras, to: extras)

        let viewModel = EventViewModel(event: event)

        XCTAssertEqual(viewModel.locationRepresentation, "Haus der Demokratiegeschichte")
    }

    func testLocationRepresentationFallsBackToStreet() async {
        let extras = EventExtras(location: nil, street: "Kastell 5")
        let event = Event
            .stub(withID: 1)
            .setting(\Event.extras, to: extras)

        let viewModel = EventViewModel(event: event)

        XCTAssertEqual(viewModel.locationRepresentation, "Kastell 5")
    }
        
    // TODO: Add Tests Subtitle with Site
    
    
}
