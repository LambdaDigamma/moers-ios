import Foundation
import ModernNetworking

nonisolated public protocol HTTPClient {
    func load(_ request: HTTPRequest) async -> HTTPResult
}
