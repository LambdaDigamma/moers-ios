//
//  Event+DisplayLocation.swift
//
//
//  Created by Codex on 17.06.26.
//

import Foundation

nonisolated public extension Event {

    var displayLocationName: String? {
        if let locationName = extras?.displayLocationName {
            return locationName
        }

        if let placeName = place?.name.trimmingCharacters(in: .whitespacesAndNewlines),
           !placeName.isEmpty {
            return placeName
        }

        return nil
    }

}
