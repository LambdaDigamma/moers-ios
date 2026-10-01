import Core
import Foundation
import ModernNetworking

nonisolated struct FixtureHTTPClient: HTTPClient, Sendable {
    private let data: Data

    init(url: URL) throws {
        data = try Data(contentsOf: url)
    }

    func load(_ request: HTTPRequest) async -> HTTPResult {
        guard let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://fixtures.invalid")!,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: [:]
        ) else {
            return .failure(HTTPError(.invalidResponse, request))
        }
        return .success(HTTPResponse(request, response, data))
    }
}
