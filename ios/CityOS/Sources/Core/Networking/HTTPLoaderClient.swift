import Foundation
import ModernNetworking

nonisolated public final class HTTPLoaderClient: HTTPClient {
    private let loader: HTTPLoader

    public init(loader: HTTPLoader) {
        self.loader = loader
    }

    public func load(_ request: HTTPRequest) async -> HTTPResult {
        await loader.load(request)
    }
}
