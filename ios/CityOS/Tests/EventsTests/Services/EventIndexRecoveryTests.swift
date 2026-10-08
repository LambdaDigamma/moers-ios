import Core
import Foundation
import XCTest
@testable import Events

@MainActor
final class EventIndexRecoveryTests: XCTestCase {
    func testPagesOverlapAndReturnStableOrderWithUniqueIdentifiers() async throws {
        let client = PagedEventHTTPClient(responses: [
            1: page(1, last: 6, identifiers: [1]),
            2: page(2, last: 6, identifiers: [2]),
            3: page(3, last: 6, identifiers: [2, 3]),
            4: page(4, last: 6, identifiers: [4]),
            5: page(5, last: 6, identifiers: [5]),
            6: page(6, last: 6, identifiers: [6])
        ], concurrentPageGate: 3)
        let response = try await DefaultEventService(client: client).index(cacheMode: .revalidate, withPages: false)
        XCTAssertEqual(response.data.map(\.id), [1, 2, 3, 4, 5, 6])
        let requests = await client.requests
        XCTAssertEqual(requests.compactMap { request in
            Int(request.queryItems.first { $0.name == "page[number]" }?.value ?? "")
        }.sorted(), [1, 2, 3, 4, 5, 6])
        let maximumInFlight = await client.maximumInFlight
        XCTAssertEqual(maximumInFlight, 3)
    }

    func testLaterPageFailurePreservesPartialEventsWithoutReturningSuccess() async throws {
        let client = PagedEventHTTPClient(responses: [1: page(1, last: 3, identifiers: [1]), 3: page(3, last: 3, identifiers: [3])])
        var updates: [[Event.ID]] = []
        do {
            _ = try await DefaultEventService(client: client).index(cacheMode: .revalidate, withPages: false) { updates.append($0.map(\.id)) }
            XCTFail("An incomplete index must not replace repository data")
        } catch let error as EventIndexLoadError {
            XCTAssertEqual(error.events.map(\.id), [1, 3])
            XCTAssertEqual(error.failedPages, [2])
            XCTAssertEqual(updates.first, [1])
            XCTAssertEqual(updates.last, [1, 3])
        }
    }

    func testCancellationDoesNotBecomePartialFailure() async throws {
        let client = PagedEventHTTPClient(responses: [1: page(1, last: 2, identifiers: [1]), 2: page(2, last: 2, identifiers: [2])], waitsForCancellation: true)
        let task = Task {
            _ = try await DefaultEventService(client: client).index(cacheMode: .revalidate, withPages: false)
        }
        await client.waitForLaterPage()
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("A cancelled load must not succeed")
        } catch is CancellationError {
            // The controller can ignore cancellation without showing a retry warning.
        }
    }

    func testDefaultProgressCallbackDoesNotPublishAfterCancellation() async throws {
        let service = GatedEventService()
        var published = false
        let task = Task {
            _ = try await service.index(cacheMode: .revalidate, withPages: false) { _ in published = true }
        }
        await service.waitForIndexRequest()
        task.cancel()
        service.complete()
        do {
            try await task.value
            XCTFail("The default progress implementation must preserve cancellation")
        } catch is CancellationError {
            XCTAssertFalse(published)
        }
    }

    private func page(_ number: Int, last: Int, identifiers: [Int]) -> Data {
        let events = identifiers.map { "{\"id\":\($0),\"name\":\"Event \($0)\"}" }.joined(separator: ",")
        return Data("{\"data\":[\(events)],\"links\":[],\"meta\":{\"current_page\":\(number),\"last_page\":\(last)}}".utf8)
    }
}
