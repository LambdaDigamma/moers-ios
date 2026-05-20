//
//  FestivalDeepLinkParserTests.swift
//  moers festival Tests
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

@MainActor
final class FestivalDeepLinkParserTests: XCTestCase {
    private let parser = FestivalDeepLinkParser()

    func testParsesCanonicalCollectionLinks() {
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///posts")!), .posts)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///events")!), .events)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///favorites")!), .favorites)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///map")!), .map)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///download-events")!), .downloadEvents)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///info")!), .info)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///legal")!), .legal)
    }

    func testParsesCanonicalDetailLinks() {
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///posts/42")!), .postDetail(postID: 42))
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///events/9001")!), .eventDetail(eventID: 9001))
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///venues/7")!), .venueDetail(venueID: 7))
    }

    func testParsesCanonicalLinksCaseInsensitively() {
        XCTAssertEqual(parser.parse(URL(string: "MOERSFESTIVAL:///Events/34")!), .eventDetail(eventID: 34))
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///FAVORITES")!), .favorites)
    }

    func testRejectsHostStyleCustomSchemeLinks() {
        XCTAssertNil(parser.parse(URL(string: "moersfestival://posts")!))
        XCTAssertNil(parser.parse(URL(string: "moersfestival://posts/42")!))
        XCTAssertNil(parser.parse(URL(string: "moersfestival://venues/7")!))
    }

    func testRejectsSingleSlashCustomSchemeLinks() {
        XCTAssertNil(parser.parse(URL(string: "moersfestival:/events")!))
        XCTAssertNil(parser.parse(URL(string: "MOERSFESTIVAL:/Events/34")!))
    }

    func testInvalidOrMissingIDsOpenOverviewWhereAvailable() {
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///posts/not-an-id")!), .posts)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///events/not-an-id")!), .events)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///venues")!), .map)
        XCTAssertEqual(parser.parse(URL(string: "moersfestival:///venues/not-an-id")!), .map)
    }

    func testRejectsAliasesAndUnknownPaths() {
        XCTAssertNil(parser.parse(URL(string: "moersfestival:///news")!))
        XCTAssertNil(parser.parse(URL(string: "moersfestival:///spielplan")!))
        XCTAssertNil(parser.parse(URL(string: "moersfestival:///veranstaltungen")!))
        XCTAssertNil(parser.parse(URL(string: "moersfestival:///unknown")!))
    }
}
