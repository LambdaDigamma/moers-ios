//
//  FestivalWidgetDataStore.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

enum FestivalWidgetDataStore {

    static func loadEvents() async throws -> [FestivalWidgetEvent] {
        let url = WidgetConstants.baseAPIURL.appendingPathComponent("events")

        do {
            let events: [FestivalWidgetEvent] = try await fetchCollection(
                from: url,
                cacheFilename: WidgetConstants.eventsCacheFilename
            )
            return events
        } catch {
            if let cached: [FestivalWidgetEvent] = try loadCache(named: WidgetConstants.eventsCacheFilename) {
                return cached
            }
            throw error
        }
    }

    static func loadVenues() async throws -> [FestivalWidgetVenue] {
        let url = WidgetConstants.baseAPIURL.appendingPathComponent("locations")

        do {
            let venues: [FestivalWidgetVenue] = try await fetchCollection(
                from: url,
                cacheFilename: WidgetConstants.venuesCacheFilename
            )
            return venues.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            if let cached: [FestivalWidgetVenue] = try loadCache(named: WidgetConstants.venuesCacheFilename) {
                return cached.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
            throw error
        }
    }

    static func loadFavoriteEventIDs() -> Set<Int> {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroupID)
        let ids = defaults?.array(forKey: WidgetConstants.favoriteEventIDsKey) as? [Int] ?? []
        return Set(ids)
    }

    private static func fetchCollection<T: Decodable>(
        from url: URL,
        cacheFilename: String
    ) async throws -> [T] {
        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        let decoder = festivalWidgetDecoder()
        let decoded = try decoder.decode(FestivalWidgetCollectionResponse<T>.self, from: data)
        try storeCache(data, named: cacheFilename)
        return decoded.data
    }

    private static func storeCache(_ data: Data, named filename: String) throws {
        let cacheURL = try cacheFileURL(named: filename)
        try data.write(to: cacheURL, options: [.atomic])
    }

    private static func loadCache<T: Decodable>(named filename: String) throws -> [T]? {
        let cacheURL = try cacheFileURL(named: filename)

        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: cacheURL)
        let decoder = festivalWidgetDecoder()
        return try decoder.decode(FestivalWidgetCollectionResponse<T>.self, from: data).data
    }

    private static func cacheFileURL(named filename: String) throws -> URL {
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetConstants.appGroupID) {
            return containerURL.appendingPathComponent(filename, isDirectory: false)
        }

        return FileManager.default.temporaryDirectory.appendingPathComponent(filename, isDirectory: false)
    }

    private static func festivalWidgetDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let stringValue = try container.decode(String.self)

            let formatters: [DateFormatter] = [
                {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                    return formatter
                }(),
                {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    return formatter
                }()
            ]

            for formatter in formatters {
                if let date = formatter.date(from: stringValue) {
                    return date
                }
            }

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: stringValue) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported date format: \(stringValue)"
            )
        }
        return decoder
    }

}
