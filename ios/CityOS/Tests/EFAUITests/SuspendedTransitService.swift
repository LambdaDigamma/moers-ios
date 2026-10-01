import XCTest
@testable import EFAAPI

@MainActor
final class SuspendedTransitService: StaticTransitService {
    var requested: XCTestExpectation?
    private var continuation: CheckedContinuation<GeoITDRequest, Error>?

    override func geoObject(lines: [LineIdentifiable]) async throws -> GeoITDRequest {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            requested?.fulfill()
        }
    }

    func finish() async throws {
        let response = try await super.geoObject(lines: [])
        continuation?.resume(returning: response)
        continuation = nil
    }
}
