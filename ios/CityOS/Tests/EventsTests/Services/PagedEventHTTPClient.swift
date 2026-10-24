import Core
import Foundation
import ModernNetworking

actor PagedEventHTTPClient: HTTPClient {
    private let responses: [Int: Data]
    private let concurrentPageGate: Int
    private let waitsForCancellation: Bool
    private var gateWaiters: [CheckedContinuation<Void, Never>] = []
    private var startWaiters: [CheckedContinuation<Void, Never>] = []
    private var inFlight = 0
    private var gateOpened = false
    private(set) var maximumInFlight = 0
    private(set) var requests: [HTTPRequest] = []

    init(responses: [Int: Data], concurrentPageGate: Int = 1, waitsForCancellation: Bool = false) {
        self.responses = responses
        self.concurrentPageGate = concurrentPageGate
        self.waitsForCancellation = waitsForCancellation
    }

    func waitForLaterPage() async {
        if requests.count > 1 { return }
        await withCheckedContinuation { startWaiters.append($0) }
    }

    func load(_ request: HTTPRequest) async -> HTTPResult {
        requests.append(request)
        let page = Int(request.queryItems.first { $0.name == "page[number]" }?.value ?? "1") ?? 1
        if page > 1 {
            startWaiters.forEach { $0.resume() }
            startWaiters.removeAll()
            inFlight += 1
            maximumInFlight = max(maximumInFlight, inFlight)
            if !gateOpened && concurrentPageGate > 1 {
                if inFlight == concurrentPageGate {
                    gateOpened = true
                    gateWaiters.forEach { $0.resume() }
                    gateWaiters.removeAll()
                } else {
                    await withCheckedContinuation { gateWaiters.append($0) }
                }
            }
            if waitsForCancellation {
                try? await Task.sleep(for: .seconds(30))
            }
            inFlight -= 1
        }
        let response = HTTPURLResponse(url: URL(string: "https://example.com/events")!, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        return .success(HTTPResponse(request, response, responses[page] ?? Data("invalid response".utf8)))
    }
}
