//
//  EventSearchMatcher.swift
//
//
//  Created by Codex on 17.06.26.
//

import Foundation

public struct EventSearchMatcher: Sendable {

    private let normalizer: EventSearchTextNormalizer

    public init(normalizer: EventSearchTextNormalizer = EventSearchTextNormalizer()) {
        self.normalizer = normalizer
    }

    public func normalizedQuery(_ query: String) -> String {
        normalizer.normalize(query)
    }

    public func normalizedSearchText(for event: Event) -> String {
        normalizer.normalize(searchComponents(for: event).joined(separator: " "))
    }

    public func matches(_ event: Event, query: String) -> Bool {
        let query = normalizedQuery(query)

        guard !query.isEmpty else {
            return true
        }

        return normalizedSearchText(for: event).contains(query)
    }

    public func exactMatchIndexes(in events: [Event], query: String) -> Set<Int> {
        let query = normalizedQuery(query)

        guard !query.isEmpty else {
            return Set(events.indices)
        }

        return Set(events.indices.filter { index in
            normalizedSearchText(for: events[index]).contains(query)
        })
    }

    private func searchComponents(for event: Event) -> [String] {
        [
            event.name,
            event.description,
            event.category,
            event.extras?.location,
            event.extras?.street,
            event.extras?.postcode,
            event.extras?.place,
            event.extras?.organizer,
            event.place?.name,
            event.place?.streetName,
            event.place?.postalCode,
            event.place?.postalTown
        ].compactMap { component in
            guard let component else { return nil }

            let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedComponent.isEmpty ? nil : trimmedComponent
        } + (event.artists ?? []).compactMap { artist in
            guard let artist else { return nil }

            let trimmedArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedArtist.isEmpty ? nil : trimmedArtist
        }
    }

}
