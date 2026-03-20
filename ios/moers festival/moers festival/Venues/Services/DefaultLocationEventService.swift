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

nonisolated public final class DefaultLocationEventService: LocationEventService {

    nonisolated(unsafe) private let loader: HTTPLoader
    private let logger: Logger

    public init(loader: HTTPLoader) {
        self.loader = loader
        self.logger = Logger(.coreApi)
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

        for archive in archives {
            await self.updateLocalFeatures(for: archive, reset: force)
        }

        NotificationCenter.default.post(name: .updateFestivalGeoData, object: nil)

    }

    private func updateLocalFeatures(for key: String, reset: Bool = false) async {

        await MainActor.run {
            LocalFGDStore.createDirectoryIfNeeded()
        }

        guard let fileUrl = await MainActor.run(body: {
            LocalFGDStore.getFileUrl(key: key)
        }) else { return }

        let lastUpdate = LastUpdate(key: "fgd-\(key)")
        var request = HTTPRequest(path: "/fgd/\(key).geojson")

        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        if reset {
            logger.info("Resetting festival geo data for key: \(key)")
            lastUpdate.reset()
        }

        if !lastUpdate.shouldReload(ttl: .minutes(120)) {
            logger.info("Skip reloading festival geo data for key: \(key)")
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
