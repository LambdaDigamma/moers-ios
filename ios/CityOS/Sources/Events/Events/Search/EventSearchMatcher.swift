//
//  EventSearchMatcher.swift
//
//
//  Created by Codex on 17.06.26.
//

import Foundation

nonisolated public struct EventSearchMatcher: Sendable {

    private let normalizer: EventSearchTextNormalizer

    public init(normalizer: EventSearchTextNormalizer = EventSearchTextNormalizer()) {
        self.normalizer = normalizer
    }

    public func normalizedQuery(_ query: String) -> String {
        normalizer.normalize(query)
    }

    public func normalizedSearchText(for event: Event) -> String {
        normalizedVariants(searchComponents(for: event).joined(separator: " ")).joined(separator: " ")
    }

    public func matches(_ event: Event, query: String) -> Bool {
        let queries = normalizedVariants(query)
        guard !queries[0].isEmpty else { return true }
        let searchText = normalizedSearchText(for: event)
        return queries.contains { searchText.contains($0) }
    }

    public func exactMatchIndexes(in events: [Event], query: String) -> Set<Int> {
        Set(events.indices.filter { matches(events[$0], query: query) })
    }

    private func normalizedVariants(_ text: String) -> [String] {
        let normalized = normalizer.normalize(text)
        let expanded = text.precomposedStringWithCanonicalMapping.lowercased()
            .replacingOccurrences(of: "ä", with: "ae")
            .replacingOccurrences(of: "ö", with: "oe")
            .replacingOccurrences(of: "ü", with: "ue")
        let normalizedExpansion = normalizer.normalize(expanded)
        return normalized == normalizedExpansion ? [normalized] : [normalized, normalizedExpansion]
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
