//
//  EventExtras+DisplayLocation.swift
//
//

import Foundation

nonisolated public extension EventExtras {

    var displayLocationName: String? {
        trimmedNonEmpty(location)
            ?? trimmedNonEmpty(street)
            ?? trimmedNonEmpty(place)
    }

}

nonisolated private extension EventExtras {

    func trimmedNonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

}
