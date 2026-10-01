import Foundation
import Core
import ModernNetworking

nonisolated public struct RemoteAppUpdateConfiguration: Codable, Equatable, Sendable {
    public static let disabled = RemoteAppUpdateConfiguration(forceUpdate: false, enableClosing: false)

    public let forceUpdate: Bool
    public let enableClosing: Bool

    public init(forceUpdate: Bool, enableClosing: Bool) {
        self.forceUpdate = forceUpdate
        self.enableClosing = enableClosing
    }

    nonisolated enum CodingKeys: String, CodingKey {
        case forceUpdate = "force_update"
        case enableClosing = "enable_closing"
    }
}

public protocol RemoteAppUpdateConfigurationLoading: Sendable {
    func fetchConfiguration() async throws -> RemoteAppUpdateConfiguration
}

public final class RemoteAppUpdateConfigurationService: RemoteAppUpdateConfigurationLoading {
    private let client: any HTTPClient
    private let path: String

    public init(client: any HTTPClient, path: String = "/api/v1/festival/update/app/ios") {
        self.client = client
        self.path = path
    }

    @MainActor
    public convenience init(loader: HTTPLoader, path: String = "/api/v1/festival/update/app/ios") {
        self.init(client: HTTPLoaderClient(loader: loader), path: path)
    }

    public func fetchConfiguration() async throws -> RemoteAppUpdateConfiguration {
        let request = HTTPRequest(method: .get, path: path)
        let result = await client.load(request)
        let envelope = try await result.decoding(RemoteAppUpdateConfigurationEnvelope.self)

        return envelope.data
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

nonisolated struct RemoteAppUpdateConfigurationEnvelope: Model, Sendable {
    let data: RemoteAppUpdateConfiguration
}
