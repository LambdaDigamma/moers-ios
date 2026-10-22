import XCTest
@testable import EFAAPI

@MainActor
final class ControlledTransitLocationService: StaticTransitService {
    var requests: [String] = []
    var onRequest: ((String) -> Void)?
    var onResponse: ((String) -> Void)?
    private var pending: [String: CheckedContinuation<[TransitLocation], Error>] = [:]

    override func findTransitLocation(
        for searchTerm: String,
        filtering objectFilter: ObjectFilter
    ) async throws -> [TransitLocation] {
        requests.append(searchTerm)
        let locations: [TransitLocation] = try await withCheckedThrowingContinuation { continuation in
            pending[searchTerm] = continuation
            onRequest?(searchTerm)
        }
        onResponse?(searchTerm)
        return locations
    }

    func complete(_ query: String, with locations: [TransitLocation]) {
        pending.removeValue(forKey: query)?.resume(returning: locations)
    }

    nonisolated deinit {}
}
