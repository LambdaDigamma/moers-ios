import Combine
import Foundation

@MainActor
public final class AppUpdateController: ObservableObject {
    @Published public private(set) var banner: AppUpdatePresentation?
    @Published public private(set) var forcedSheet: AppUpdatePresentation?
    @Published public private(set) var isRefreshing = false

    private let statusFetcher: any AppStoreUpdateStatusFetching
    private let remoteConfigurationLoader: any RemoteAppUpdateConfigurationLoading
    private let persistence: AppUpdatePersistence
    private let fallbackStoreURL: URL

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
}

