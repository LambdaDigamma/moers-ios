//
//  EventExtras+DisplayLocation.swift
//
//

import Foundation

public extension EventExtras {

    var displayLocationName: String? {
        trimmedNonEmpty(location)
            ?? trimmedNonEmpty(street)
            ?? trimmedNonEmpty(place)
    }

}

private extension EventExtras {

    func trimmedNonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

}
