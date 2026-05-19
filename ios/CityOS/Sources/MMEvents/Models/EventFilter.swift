//
//  EventFilter.swift
//
//
//  Created by Gemini CLI on 15.03.26.
//

import Foundation

public struct EventFilter: Equatable, Hashable, Codable {

    public var venueIDs: Set<Place.ID> = []
    public var showOnlyFavorites: Bool = false

    public init(venueIDs: Set<Place.ID> = [], showOnlyFavorites: Bool = false) {
        self.venueIDs = venueIDs
        self.showOnlyFavorites = showOnlyFavorites
    }

    public var isEmpty: Bool {
        return venueIDs.isEmpty && !showOnlyFavorites
    }

    public static var empty: EventFilter {
        return EventFilter()
    }

}

@propertyWrapper
public struct PersistedFilter {
    private let key: String
    private var cachedValue: EventFilter

    public init(key: String, defaultValue: EventFilter = .empty) {
        self.key = key

        guard let data = UserDefaults.standard.data(forKey: key) else {
            self.cachedValue = defaultValue
            return
        }

        do {
            let filter = try JSONDecoder().decode(EventFilter.self, from: data)
            self.cachedValue = filter
            print("DEBUG: Restored filter for \(key): \(filter.venueIDs.count) venues, favorites only: \(filter.showOnlyFavorites)")
        } catch {
            self.cachedValue = defaultValue
            print("ERROR: Failed to decode EventFilter for key \(key): \(error)")
        }
    }

    public var wrappedValue: EventFilter {
        get {
            cachedValue
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                cachedValue = newValue
                UserDefaults.standard.set(data, forKey: key)
                print("DEBUG: Persisted filter for \(key): \(newValue.venueIDs.count) venues, favorites only: \(newValue.showOnlyFavorites)")
            } catch {
                print("ERROR: Failed to encode EventFilter for key \(key): \(error)")
            }
        }
    }
}
