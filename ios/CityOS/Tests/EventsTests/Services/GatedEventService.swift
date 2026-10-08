import Foundation
import ModernNetworking
@testable import Events

@MainActor
final class GatedEventService: EventService {
    private var hasStarted = false
    private var started: CheckedContinuation<Void, Never>?
    private var completion: CheckedContinuation<Void, Never>?

    func index(cacheMode: CacheMode, withPages: Bool) async throws -> ResourceCollection<Event> {
        hasStarted = true
        started?.resume()
        started = nil
        await withCheckedContinuation { completion = $0 }
        return ResourceCollection(data: [Event(id: 1, name: "Event")], links: .init(), meta: .init())
    }

    func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event> {
        throw URLError(.resourceUnavailable)
    }

    func waitForIndexRequest() async {
        guard !hasStarted else { return }
        await withCheckedContinuation { started = $0 }
    }

    func complete() {
        completion?.resume()
        completion = nil
    }
}
