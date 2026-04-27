import Foundation
import ModernNetworking

public struct RemoteAppUpdateConfiguration: Codable, Equatable, Sendable {
    public static let disabled = RemoteAppUpdateConfiguration(forceUpdate: false, enableClosing: false)

    public let forceUpdate: Bool
    public let enableClosing: Bool

    public init(forceUpdate: Bool, enableClosing: Bool) {
        self.forceUpdate = forceUpdate
        self.enableClosing = enableClosing
    }

    enum CodingKeys: String, CodingKey {
        case forceUpdate = "force_update"
        case enableClosing = "enable_closing"
    }
}

public protocol RemoteAppUpdateConfigurationLoading: Sendable {
    func fetchConfiguration() async throws -> RemoteAppUpdateConfiguration
}

public final class RemoteAppUpdateConfigurationService: RemoteAppUpdateConfigurationLoading, @unchecked Sendable {
    nonisolated(unsafe) private let loader: HTTPLoader
    private let path: String

    public init(loader: HTTPLoader, path: String = "/api/v1/festival/update/app/ios") {
        self.loader = loader
        self.path = path
    }

    public func fetchConfiguration() async throws -> RemoteAppUpdateConfiguration {
        let request = HTTPRequest(method: .get, path: path)
        let result = await loader.load(request)
        let envelope = try await result.decoding(RemoteAppUpdateConfigurationEnvelope.self)

        return envelope.data
    }
}

struct RemoteAppUpdateConfigurationEnvelope: Model {
    let data: RemoteAppUpdateConfiguration
}

