//
//  FestivalNotificationLanguageTests.swift
//  moers festival Tests
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

final class FestivalNotificationLanguageTests: XCTestCase {

    func testGermanLanguageUsesGermanTopic() {
        XCTAssertEqual(FestivalNotificationLanguage.from(languageIdentifier: "de"), .german)
        XCTAssertEqual(FestivalNotificationLanguage.german.topic, "all_de")
    }

    func testEnglishLanguageUsesEnglishTopic() {
        XCTAssertEqual(FestivalNotificationLanguage.from(languageIdentifier: "en"), .english)
        XCTAssertEqual(FestivalNotificationLanguage.english.topic, "all_en")
    }

    func testUnsupportedLanguageFallsBackToEnglishTopic() {
        XCTAssertEqual(FestivalNotificationLanguage.from(languageIdentifier: "fr"), .english)
    }

    func testRegionalGermanLanguageUsesGermanTopic() {
        XCTAssertEqual(FestivalNotificationLanguage.from(languageIdentifier: "de-DE"), .german)
    }

}
