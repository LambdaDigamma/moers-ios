//
//  DefaultLocationEventService.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Core
import Foundation
import ModernNetworking
import MMEvents
import OSLog

public final class DefaultLocationEventService: LocationEventService, @unchecked Sendable {

    nonisolated(unsafe) private let loader: HTTPLoader

    public nonisolated init(loader: HTTPLoader) {
        self.loader = loader
    }

    public func getLocations() async throws -> [Place] {

        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/locations"
        )

        let result = await loader.load(request)
        if let error = result.error {
            throw error
        }
        let resource = try await result.decoding(Resource<[Place]>.self, using: Place.decoder)
        return resource.data

    }

    public func showVenue(id: Place.ID) async throws -> Place {

        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/map/venues/\(id)"
        )

        let result = await loader.load(request)
        if let error = result.error {
            throw error
        }
        let resource = try await result.decoding(Resource<Place>.self, using: Place.decoder)
        return resource.data

    }

    public func updateLocalFestivalArchive(force: Bool) async {

        let archives = [
            FGDCollection.CodingKeys.camping.rawValue,
            FGDCollection.CodingKeys.dorf.rawValue,
            FGDCollection.CodingKeys.medicalService.rawValue,
            FGDCollection.CodingKeys.stages.rawValue,
            FGDCollection.CodingKeys.surfaces.rawValue,
            FGDCollection.CodingKeys.tickets.rawValue,
            FGDCollection.CodingKeys.toilets.rawValue,
            FGDCollection.CodingKeys.transporation.rawValue,
        ]

        // Resolve file URLs on the main actor once before spawning concurrent tasks.
        let fileUrls: [String: URL] = await MainActor.run {
            LocalFGDStore.createDirectoryIfNeeded()
            return Dictionary(
                archives.compactMap { key in
                    LocalFGDStore.getFileUrl(key: key).map { (key, $0) }
                },
                uniquingKeysWith: { first, _ in first }
            )
        }

        await withTaskGroup(of: Void.self) { group in
            for archive in archives {
                guard let fileUrl = fileUrls[archive] else { continue }
                group.addTask { await self.updateLocalFeatures(for: archive, fileUrl: fileUrl, reset: force) }
            }
        }

        await MainActor.run {
            NotificationCenter.default.post(name: .updateFestivalGeoData, object: nil)
        }

    }

    private func updateLocalFeatures(for key: String, fileUrl: URL, reset: Bool = false) async {

        let lastUpdate = LastUpdate(key: "fgd-\(key)")
        var request = HTTPRequest(path: "/fgd/\(key).geojson")

        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        if reset {
            lastUpdate.reset()
        }

        if !lastUpdate.shouldReload(ttl: .minutes(120)) {
            return
        }

        let result = await loader.load(request)

        if let error = result.error {
            lastUpdate.reset()
            print(error)
            return
        }

        if let body = result.response?.body {
            try? body.write(to: fileUrl)
            lastUpdate.setNow()
        }

    }

}
