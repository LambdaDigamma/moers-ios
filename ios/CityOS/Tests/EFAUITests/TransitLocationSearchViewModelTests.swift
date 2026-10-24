import XCTest
import Foundation
import EFAAPI
@testable import EFAUI

@MainActor
final class TransitLocationSearchViewModelTests: XCTestCase {
    func testQueryChangeRejectsPreviousResponseDuringDebounce() async {
        let service = ControlledTransitLocationService()
        let model = TransitLocationSearchViewModel(service: service)
        await startSearch("Moers", model: model, service: service)
        model.searchTerm = "Duisburg"
        XCTAssertEqual(service.requests, ["Moers"])

        let returned = expectation(description: "Previous response returned")
        service.onResponse = { _ in returned.fulfill() }
        service.complete("Moers", with: [.init(name: "Old stop", description: "Moers")])
        await fulfillment(of: [returned], timeout: 2)
        XCTAssertTrue(model.transitLocations.isEmpty)
        model.searchTerm = ""
    }

    func testClearingQueryRejectsPendingResponse() async {
        let service = ControlledTransitLocationService()
        let model = TransitLocationSearchViewModel(service: service)
        await startSearch("Moers", model: model, service: service)
        model.searchTerm = ""
        let returned = expectation(description: "Cleared response returned")
        service.onResponse = { _ in returned.fulfill() }
        service.complete("Moers", with: [.init(name: "Old stop", description: "Moers")])
        await fulfillment(of: [returned], timeout: 2)
        XCTAssertTrue(model.transitLocations.isEmpty)
        XCTAssertFalse(model.searchActive)
        XCTAssertEqual(service.requests, ["Moers"])
    }

    func testQueryChangeImmediatelyClearsSelectableResults() async {
        let service = ControlledTransitLocationService()
        let model = TransitLocationSearchViewModel(service: service)
        await startSearch("Moers", model: model, service: service)
        let returned = expectation(description: "Initial response returned")
        service.onResponse = { _ in returned.fulfill() }
        service.complete("Moers", with: [.init(name: "Moers Bahnhof", description: "Moers")])
        await fulfillment(of: [returned], timeout: 2)
        XCTAssertEqual(model.transitLocations.map(\.name), ["Moers Bahnhof"])

        model.searchTerm = "Duisburg"
        XCTAssertTrue(model.transitLocations.isEmpty)
        model.searchTerm = ""
    }

    func testReturningToPreviousQueryRestartsCancelledSearch() async {
        let service = ControlledTransitLocationService()
        let model = TransitLocationSearchViewModel(service: service)
        await startSearch("Moers", model: model, service: service)
        model.searchTerm = "Duisburg"
        model.searchTerm = "Moers"
        service.complete("Moers", with: [])

        let restarted = expectation(description: "Previous query restarted")
        service.onRequest = { _ in restarted.fulfill() }
        await fulfillment(of: [restarted], timeout: 2)
        XCTAssertEqual(service.requests, ["Moers", "Moers"])
        let returned = expectation(description: "Current response returned")
        service.onResponse = { _ in returned.fulfill() }
        service.complete("Moers", with: [.init(name: "Moers Bahnhof", description: "Moers")])
        await fulfillment(of: [returned], timeout: 2)
        XCTAssertEqual(model.transitLocations.map(\.name), ["Moers Bahnhof"])
    }

    func testPendingSearchDoesNotKeepReleasedModelAlive() async throws {
        let service = ControlledTransitLocationService()
        var model: TransitLocationSearchViewModel? = TransitLocationSearchViewModel(service: service)
        await startSearch("Moers", model: try XCTUnwrap(model), service: service)
        weak let releasedModel = model
        model = nil
        XCTAssertNil(releasedModel)

        let returned = expectation(description: "Released search response returned")
        service.onResponse = { _ in returned.fulfill() }
        service.complete("Moers", with: [])
        await fulfillment(of: [returned], timeout: 2)
    }

    func testSynchronousReleasePreservesTaskLocalScope() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                TransitSearchTaskLocal.$marker.withValue(17) {
                    weak var releasedModel: TransitLocationSearchViewModel?
                    autoreleasepool {
                        var model: TransitLocationSearchViewModel? = TransitLocationSearchViewModel(service: StaticTransitService())
                        releasedModel = model
                        model = nil
                    }
                    XCTAssertNil(releasedModel)
                    XCTAssertEqual(TransitSearchTaskLocal.marker, 17)
                }
                XCTAssertEqual(TransitSearchTaskLocal.marker, 0)
                continuation.resume()
            }
        }
    }

    private func startSearch(
        _ query: String,
        model: TransitLocationSearchViewModel,
        service: ControlledTransitLocationService
    ) async {
        let started = expectation(description: "Search started")
        service.onRequest = { _ in started.fulfill() }
        model.searchTerm = query
        await fulfillment(of: [started], timeout: 2)
        service.onRequest = nil
    }
}
