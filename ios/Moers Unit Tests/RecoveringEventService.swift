import Foundation
import Events
import ModernNetworking

@MainActor
final class RecoveringEventService: EventService {
    private let events: [Event]
    private let failsFirstRequest: Bool
    private(set) var requestCount = 0

    init(events: [Event], failsFirstRequest: Bool = true) {
        self.events = events
        self.failsFirstRequest = failsFirstRequest
    }

    func index(cacheMode: CacheMode, withPages: Bool) async throws -> ResourceCollection<Event> {
        try await index(cacheMode: cacheMode, withPages: withPages, onPage: { _ in })
    }

    func index(cacheMode: CacheMode, withPages: Bool, onPage: @escaping @MainActor @Sendable ([Event]) -> Void) async throws -> ResourceCollection<Event> {
        requestCount += 1
        onPage(events)
        if failsFirstRequest && requestCount == 1 {
            throw EventIndexLoadError(events: events, failedPages: [2])
        }
        return ResourceCollection(data: events, links: .init(), meta: .init())
    }

    func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event> {
        guard let event = events.first(where: { $0.id == eventID }) else { throw URLError(.resourceUnavailable) }
        return Resource(data: event)
    }
}
