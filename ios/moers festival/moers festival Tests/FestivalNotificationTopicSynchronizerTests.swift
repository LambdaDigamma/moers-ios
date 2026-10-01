//
//  FestivalNotificationTopicSynchronizerTests.swift
//  moers festival Tests
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

@MainActor
final class FestivalNotificationTopicSynchronizerTests: XCTestCase {

    private var userDefaults: UserDefaults!
    private var suiteName: String!
    private var subscribedTopics: [String]!
    private var unsubscribedTopics: [String]!

    override func setUp() async throws {
        try await super.setUp()

        suiteName = "FestivalNotificationTopicSynchronizerTests-\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        subscribedTopics = []
        unsubscribedTopics = []
    }

    override func tearDown() async throws {
        if let suiteName {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }

        userDefaults = nil
        suiteName = nil
        subscribedTopics = nil
        unsubscribedTopics = nil

        try await super.tearDown()
    }

    func testSyncSubscribesGeneralAndCurrentLanguageTopics() async {
        let synchronizer = makeSynchronizer(language: .german)

        synchronizer.sync()

        XCTAssertEqual(subscribedTopics, ["all", "all_de"])
        XCTAssertEqual(unsubscribedTopics, [])
        XCTAssertEqual(
            userDefaults.string(forKey: FestivalNotificationTopicSynchronizer.lastLanguageTopicKey),
            "all_de"
        )
        XCTAssertEqual(
            userDefaults.integer(forKey: FestivalNotificationTopicSynchronizer.syncVersionKey),
            FestivalNotificationTopicSynchronizer.syncVersion
        )
    }

    func testSyncFallsBackToEnglishLanguageTopic() async {
        let synchronizer = makeSynchronizer(language: .english)

        synchronizer.sync()

        XCTAssertEqual(subscribedTopics, ["all", "all_en"])
        XCTAssertEqual(
            userDefaults.string(forKey: FestivalNotificationTopicSynchronizer.lastLanguageTopicKey),
            "all_en"
        )
    }

    func testSyncUnsubscribesPreviousLanguageTopicAfterSubscribingNewTopic() async {
        userDefaults.set("all_en", forKey: FestivalNotificationTopicSynchronizer.lastLanguageTopicKey)
        userDefaults.set(
            FestivalNotificationTopicSynchronizer.syncVersion,
            forKey: FestivalNotificationTopicSynchronizer.syncVersionKey
        )

        let synchronizer = makeSynchronizer(language: .german)

        synchronizer.sync()

        XCTAssertEqual(subscribedTopics, ["all", "all_de"])
        XCTAssertEqual(unsubscribedTopics, ["all_en"])
        XCTAssertEqual(
            userDefaults.string(forKey: FestivalNotificationTopicSynchronizer.lastLanguageTopicKey),
            "all_de"
        )
    }

    func testSyncSkipsFirebaseOperationsWithoutToken() async {
        let synchronizer = makeSynchronizer(language: .german, token: nil)

        synchronizer.sync()

        XCTAssertEqual(subscribedTopics, [])
        XCTAssertEqual(unsubscribedTopics, [])
        XCTAssertNil(userDefaults.string(forKey: FestivalNotificationTopicSynchronizer.lastLanguageTopicKey))
    }

    func testSyncDoesNotPersistStateWhenLanguageSubscriptionFails() async {
        let synchronizer = makeSynchronizer(
            language: .german,
            failingSubscribeTopic: "all_de"
        )

        synchronizer.sync()

        XCTAssertEqual(subscribedTopics, ["all", "all_de"])
        XCTAssertNil(userDefaults.string(forKey: FestivalNotificationTopicSynchronizer.lastLanguageTopicKey))
        XCTAssertEqual(userDefaults.integer(forKey: FestivalNotificationTopicSynchronizer.syncVersionKey), 0)
    }

    private func makeSynchronizer(
        language: FestivalNotificationLanguage,
        token: String? = "token",
        failingSubscribeTopic: String? = nil
    ) -> FestivalNotificationTopicSynchronizer {
        return FestivalNotificationTopicSynchronizer(
            userDefaults: userDefaults,
            languageProvider: { language },
            tokenProvider: { token },
            subscribeToTopic: { [weak self] topic, completion in
                self?.subscribedTopics.append(topic)

                if topic == failingSubscribeTopic {
                    completion(NSError(domain: "FCM", code: 1))
                    return
                }

                completion(nil)
            },
            unsubscribeFromTopic: { [weak self] topic, completion in
                self?.unsubscribedTopics.append(topic)
                completion(nil)
            }
        )
    }

}
