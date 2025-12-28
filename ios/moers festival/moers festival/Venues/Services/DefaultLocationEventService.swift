//
//  DefaultLocationEventService.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Core
import Combine
import Foundation
import ModernNetworking
import MMEvents
import OSLog

public class DefaultLocationEventService: LocationEventService {
    
    private let loader: HTTPLoader
    private let logger: Logger
    
    public init(loader: HTTPLoader) {
        self.loader = loader
        self.logger = Logger(.coreApi)
    }
    
    public func getLocations() -> AnyPublisher<[Place], Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/locations"
        )
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .compactMap { $0.body }
        .decode(type: Resource<[Place]>.self, decoder: Place.decoder)
        .map({
            return $0.data
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    public func showVenue(id: Place.ID) -> AnyPublisher<Place, Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/map/venues/\(id)"
        )
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .compactMap { $0.body }
        .decode(type: Resource<Place>.self, decoder: Place.decoder)
        .map({
            return $0.data
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
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
        
        await withTaskGroup(of: Void.self) { group in
            for archive in archives {
                group.addTask {
                    await self.updateLocalFeatures(for: archive, reset: force)
                }
            }
        }
        
        NotificationCenter.default.post(name: .updateFestivalGeoData, object: nil)
        
    }
    
    private func updateLocalFeatures(for key: String, reset: Bool = false) async {
        
        LocalFGDStore.createDirectoryIfNeeded()
        
        guard let fileUrl = LocalFGDStore.getFileUrl(key: key) else { return }
        
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
        
        switch result {
            case .success(let response):
                try? response.body?.write(to: fileUrl)
                lastUpdate.setNow()
            case .failure(let error):
                lastUpdate.reset()
                print(error)
        }
        
    }
    
}
