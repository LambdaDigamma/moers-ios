import Core
import Foundation
import ModernNetworking

actor CityEventHTTPClient: HTTPClient {
    private let data: Data
    private(set) var requests: [HTTPRequest] = []

    init(json: String) {
        data = Data(json.utf8)
    }

    func load(_ request: HTTPRequest) async -> HTTPResult {
        requests.append(request)
        let url = URL(string: "https://fixtures.invalid/\(request.path)")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return .success(HTTPResponse(request, response, data))
    }
}
