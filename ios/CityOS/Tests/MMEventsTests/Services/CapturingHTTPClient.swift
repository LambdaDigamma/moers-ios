//
//  CapturingHTTPClient.swift
//
//
//  Created by Codex on 28.06.26.
//

import Foundation
import Core
import ModernNetworking

actor CapturingHTTPClient: HTTPClient {

    private(set) var requests: [HTTPRequest] = []
    private var responses: [Data]
    private let statusCode: Int

    init(data: Data, statusCode: Int = 200) {
        self.responses = [data]
        self.statusCode = statusCode
    }

    init(responses: [Data], statusCode: Int = 200) {
        self.responses = responses
        self.statusCode = statusCode
    }

    func load(_ request: HTTPRequest) async -> HTTPResult {
        requests.append(request)
        let data = responses.isEmpty ? Data() : responses[min(requests.count - 1, responses.count - 1)]

        let path = request.path.hasPrefix("/") ? request.path : "/\(request.path)"
        let url = URL(string: "https://moers.app\(path)")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "1.1",
            headerFields: ["Content-Type": "application/json"]
        )!

        return .success(HTTPResponse(request, response, data))
    }

}
