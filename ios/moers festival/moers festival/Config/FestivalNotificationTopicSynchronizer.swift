//
//  FestivalNotificationTopicSynchronizer.swift
//  moers festival
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import FirebaseMessaging
import Foundation
import OSLog
import UserNotifications

@MainActor
final class FestivalNotificationTopicSynchronizer {

    typealias TopicCompletion = @MainActor @Sendable (Error?) -> Void
    typealias TopicOperation = @MainActor (String, @escaping TopicCompletion) -> Void

    static let shared = FestivalNotificationTopicSynchronizer(
        userDefaults: .standard,
        languageProvider: { FestivalNotificationLanguage.current },
        tokenProvider: { Messaging.messaging().fcmToken },
        subscribeToTopic: { topic, completion in
            Messaging.messaging().subscribe(toTopic: topic) { error in
                Task { @MainActor in
                    completion(error)
                }
            }
        },
        unsubscribeFromTopic: { topic, completion in
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                Task { @MainActor in
                    completion(error)
                }
            }
        }
    )

    static let syncVersion = 2
    static let lastLanguageTopicKey = "festival.notificationTopic.language"
    static let syncVersionKey = "festival.notificationTopic.syncVersion"

    private let userDefaults: UserDefaults
    private let languageProvider: () -> FestivalNotificationLanguage
    private let tokenProvider: () -> String?
    private let subscribeToTopic: TopicOperation
    private let unsubscribeFromTopic: TopicOperation
    private let logger = Logger(.default)

    init(
        userDefaults: UserDefaults,
        languageProvider: @escaping () -> FestivalNotificationLanguage,
        tokenProvider: @escaping () -> String?,
        subscribeToTopic: @escaping TopicOperation,
        unsubscribeFromTopic: @escaping TopicOperation
    ) {
        self.userDefaults = userDefaults
        self.languageProvider = languageProvider
        self.tokenProvider = tokenProvider
        self.subscribeToTopic = subscribeToTopic
        self.unsubscribeFromTopic = unsubscribeFromTopic
    }

    func syncIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    Task { @MainActor in
                        self?.sync()
                    }
                default:
                    break
            }
        }
    }

    func sync() {
        guard let token = tokenProvider(), token.isEmpty == false else {
            logger.info("Skipping FCM topic sync because no registration token is available.")
            return
        }

        let languageTopic = languageProvider().topic
        let previousLanguageTopic = userDefaults.string(forKey: Self.lastLanguageTopicKey)

        subscribeToTopic("all") { [weak self] error in
            guard let self else { return }

            if let error {
                self.logger.error("FCM topic subscription failed: \(error.localizedDescription)")
                return
            }

            self.subscribeToTopic(languageTopic) { [weak self] error in
                guard let self else { return }

                if let error {
                    self.logger.error("Language FCM topic subscription failed: \(error.localizedDescription)")
                    return
                }

                self.unsubscribeFromStaleLanguageTopic(
                    previousLanguageTopic,
                    currentLanguageTopic: languageTopic
                )
            }
        }
    }

    private func unsubscribeFromStaleLanguageTopic(
        _ previousLanguageTopic: String?,
        currentLanguageTopic: String
    ) {
        guard
            let previousLanguageTopic,
            previousLanguageTopic != currentLanguageTopic,
            FestivalNotificationLanguage.languageTopics.contains(previousLanguageTopic)
        else {
            persistSyncedTopic(currentLanguageTopic)
            return
        }

        unsubscribeFromTopic(previousLanguageTopic) { [weak self] error in
            guard let self else { return }

            if let error {
                self.logger.error("Stale FCM topic unsubscribe failed: \(error.localizedDescription)")
                return
            }

            self.persistSyncedTopic(currentLanguageTopic)
        }
    }

    private func persistSyncedTopic(_ languageTopic: String) {
        userDefaults.set(languageTopic, forKey: Self.lastLanguageTopicKey)
        userDefaults.set(Self.syncVersion, forKey: Self.syncVersionKey)
    }
}
