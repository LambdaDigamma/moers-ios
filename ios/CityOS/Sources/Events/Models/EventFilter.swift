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
    private let defaultValue: EventFilter

    public init(key: String, defaultValue: EventFilter = .empty) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: EventFilter {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return defaultValue
            }
            do {
                let filter = try JSONDecoder().decode(EventFilter.self, from: data)
                print("DEBUG: Restored filter for \(key): \(filter.venueIDs.count) venues, favorites only: \(filter.showOnlyFavorites)")
                return filter
            } catch {
                print("ERROR: Failed to decode EventFilter for key \(key): \(error)")
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: key)
                print("DEBUG: Persisted filter for \(key): \(newValue.venueIDs.count) venues, favorites only: \(newValue.showOnlyFavorites)")
            } catch {
                print("ERROR: Failed to encode EventFilter for key \(key): \(error)")
            }
        }
    }
}

