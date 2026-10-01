import Combine
import Foundation
import Observation

@MainActor
@Observable
public final class AppUpdateController {
    public private(set) var banner: AppUpdatePresentation? {
        didSet {
            bannerSubject.send(banner)
        }
    }
    public private(set) var forcedSheet: AppUpdatePresentation? {
        didSet {
            forcedSheetSubject.send(forcedSheet)
        }
    }
    public private(set) var isRefreshing = false

    @ObservationIgnored
    private let bannerSubject = CurrentValueSubject<AppUpdatePresentation?, Never>(nil)
    @ObservationIgnored
    private let forcedSheetSubject = CurrentValueSubject<AppUpdatePresentation?, Never>(nil)
    private let statusFetcher: any AppStoreUpdateStatusFetching
    private let remoteConfigurationLoader: any RemoteAppUpdateConfigurationLoading
    private let persistence: AppUpdatePersistence
    private let fallbackStoreURL: URL

    public var bannerPublisher: AnyPublisher<AppUpdatePresentation?, Never> {
        bannerSubject.eraseToAnyPublisher()
    }

    public var forcedSheetPublisher: AnyPublisher<AppUpdatePresentation?, Never> {
        forcedSheetSubject.eraseToAnyPublisher()
    }

    public init(
        statusFetcher: any AppStoreUpdateStatusFetching,
        remoteConfigurationLoader: any RemoteAppUpdateConfigurationLoading,
        persistence: AppUpdatePersistence = AppUpdatePersistence(),
        fallbackStoreURL: URL
    ) {
        self.statusFetcher = statusFetcher
        self.remoteConfigurationLoader = remoteConfigurationLoader
        self.persistence = persistence
        self.fallbackStoreURL = fallbackStoreURL
    }

    public func refresh() async {
        guard isRefreshing == false else { return }

        isRefreshing = true
        defer { isRefreshing = false }

        let remoteConfiguration = (try? await remoteConfigurationLoader.fetchConfiguration()) ?? .disabled

        do {
            let status = try await statusFetcher.fetchStatus()
            apply(status: status, remoteConfiguration: remoteConfiguration)
        } catch {
            applyLookupFailure(remoteConfiguration: remoteConfiguration)
        }
    }

    public func dismissBanner() {
        if let version = banner?.version {
            persistence.dismissBanner(for: version)
        }

        banner = nil
    }

    public func dismissForcedSheet() {
        forcedSheet = nil
    }

    private func apply(status: AppStoreUpdateStatus, remoteConfiguration: RemoteAppUpdateConfiguration) {
        switch status {
            case .newerVersionInstalled, .upToDate:
                banner = nil
                forcedSheet = nil

            case .updateAvailable(let update):
                let presentation = AppUpdatePresentation(
                    version: update.version,
                    storeURL: update.storeURL,
                    allowsDismissal: remoteConfiguration.enableClosing
                )

                if remoteConfiguration.forceUpdate {
                    banner = nil
                    forcedSheet = presentation
                } else {
                    forcedSheet = nil
                    banner = persistence.didDismissBanner(for: update.version) ? nil : AppUpdatePresentation(
                        version: update.version,
                        storeURL: update.storeURL,
                        allowsDismissal: true
                    )
                }
        }
    }

    private func applyLookupFailure(remoteConfiguration: RemoteAppUpdateConfiguration) {
        banner = nil

        if remoteConfiguration.forceUpdate {
            forcedSheet = AppUpdatePresentation(
                version: nil,
                storeURL: fallbackStoreURL,
                allowsDismissal: remoteConfiguration.enableClosing
            )
        } else {
            forcedSheet = nil
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
