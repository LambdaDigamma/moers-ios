//
//  DefaultPlaceService.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import Combine
import Factory
import ModernNetworking
import OSLog

public class DefaultPlaceService: PlaceService {
    
    private let loader: HTTPLoader
    private let logger: Logger
    
    public init(loader: HTTPLoader) {
        self.loader = loader
        self.logger = Logger(.coreApi)
    }
    
    public func getPlaces() -> AnyPublisher<[Place], Error> {
        
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
    
    public func getPlaces() async throws -> ResourceCollection<Place> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/locations"
        )
        
        let result = await self.loader.load(request)
        
        if let error = result.error {
            throw error
        }
        
        return try await result.decoding(ResourceCollection<Place>.self)
        
    }
    
    public func getPlace(placeID: Place.ID) async throws -> Place {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/locations/\(placeID)"
        )
        
        let result = await self.loader.load(request)
        
        if let error = result.error {
            throw error
        }
        
        return try await result.decoding(Place.self)
        
    }
    
}
