@testable import AppUpdateFeature
import Foundation
import Testing

@Suite("AppUpdateFeature")
struct AppUpdateFeatureTests {
    @Test("Compares numeric app versions")
    func comparesNumericVersions() {
        #expect(AppVersion.compare("2.10.0", "2.9.9") == .orderedDescending)
        #expect(AppVersion.compare("2.4", "2.4.0") == .orderedSame)
        #expect(AppVersion.compare("1.0.0", "1.0.1") == .orderedAscending)
    }

    @Test("Decodes App Store lookup and reports available update")
    func decodesAppStoreLookup() async throws {
        let fetcher = AppStoreUpdateStatusFetcher(
            lookup: .appID("123456"),
            currentVersionProvider: { "2.4.1" },
            dataLoader: { _ in
                Data("""
                {
                    "results": [
                        {
                            "version": "2.5.0",
                            "trackViewUrl": "https://apps.apple.com/app/id123456"
                        }
                    ]
                }
                """.utf8)
            }
        )

        let status = try await fetcher.fetchStatus()

        guard case .updateAvailable(let update) = status else {
            Issue.record("Expected an available update.")
            return
        }

        #expect(update.version == "2.5.0")
        #expect(update.storeURL.absoluteString == "https://apps.apple.com/app/id123456")
    }

    @Test("Decodes remote force update config")
    func decodesRemoteForceUpdateConfig() throws {
        let envelope = try JSONDecoder().decode(
            RemoteAppUpdateConfigurationEnvelope.self,
            from: Data("""
            {
                "data": {
                    "force_update": true,
                    "enable_closing": true
                }
            }
            """.utf8)
        )

        #expect(envelope.data == RemoteAppUpdateConfiguration(forceUpdate: true, enableClosing: true))
    }

    @Test("Persists banner dismissal per version")
    func persistsBannerDismissalPerVersion() throws {
        let suiteName = "AppUpdateFeatureTests.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let persistence = AppUpdatePersistence(userDefaults: userDefaults, keyPrefix: "test")

        #expect(persistence.didDismissBanner(for: "2.5.0") == false)
        persistence.dismissBanner(for: "2.5.0")
        #expect(persistence.didDismissBanner(for: "2.5.0") == true)
        #expect(persistence.didDismissBanner(for: "2.6.0") == false)
    }

    @MainActor
    @Test("Shows soft banner only when update is available and not dismissed")
    func showsSoftBanner() async throws {
        let userDefaults = try #require(UserDefaults(suiteName: "AppUpdateFeatureTests.\(UUID().uuidString)"))
        let controller = AppUpdateController(
            statusFetcher: StubStatusFetcher(result: .success(.updateAvailable(.fixture(version: "2.5.0")))),
            remoteConfigurationLoader: StubRemoteConfigurationLoader(configuration: .disabled),
            persistence: AppUpdatePersistence(userDefaults: userDefaults, keyPrefix: "test"),
            fallbackStoreURL: .fallback
        )

        await controller.refresh()

        #expect(controller.banner?.version == "2.5.0")
        #expect(controller.forcedSheet == nil)

        controller.dismissBanner()
        await controller.refresh()

        #expect(controller.banner == nil)
    }

    @MainActor
    @Test("Shows forced sheet with fallback URL when lookup fails")
    func showsForcedSheetWithFallbackOnLookupFailure() async {
        let controller = AppUpdateController(
            statusFetcher: StubStatusFetcher(result: .failure(StubError.lookupFailed)),
            remoteConfigurationLoader: StubRemoteConfigurationLoader(
                configuration: RemoteAppUpdateConfiguration(forceUpdate: true, enableClosing: false)
            ),
            fallbackStoreURL: .fallback
        )

        await controller.refresh()

        #expect(controller.banner == nil)
        #expect(controller.forcedSheet?.version == nil)
        #expect(controller.forcedSheet?.storeURL == .fallback)
        #expect(controller.forcedSheet?.allowsDismissal == false)
    }

    @MainActor
    @Test("Does not force update when installed version is current")
    func doesNotForceWhenCurrent() async {
        let controller = AppUpdateController(
            statusFetcher: StubStatusFetcher(result: .success(.upToDate)),
            remoteConfigurationLoader: StubRemoteConfigurationLoader(
                configuration: RemoteAppUpdateConfiguration(forceUpdate: true, enableClosing: false)
            ),
            fallbackStoreURL: .fallback
        )

        await controller.refresh()

        #expect(controller.banner == nil)
        #expect(controller.forcedSheet == nil)
    }

}

private struct StubStatusFetcher: AppStoreUpdateStatusFetching {
    let result: Result<AppStoreUpdateStatus, StubError>

    func fetchStatus() async throws -> AppStoreUpdateStatus {
        try result.get()
    }
}

private struct StubRemoteConfigurationLoader: RemoteAppUpdateConfigurationLoading {
    let configuration: RemoteAppUpdateConfiguration

    func fetchConfiguration() async throws -> RemoteAppUpdateConfiguration {
        configuration
    }
}

private enum StubError: Error, Sendable {
    case lookupFailed
}

private extension AppStoreUpdate {
    static func fixture(version: String) -> AppStoreUpdate {
        AppStoreUpdate(version: version, storeURL: URL(string: "https://apps.apple.com/app/id123456")!)
    }
}

private extension URL {
    static let fallback = URL(string: "itms-apps://itunes.apple.com/app/id123456")!
}
