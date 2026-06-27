//
//  DefaultPlaceService.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import Core
import FactoryKit
import ModernNetworking
import OSLog

public class DefaultPlaceService: PlaceService {
    
    private let client: any HTTPClient
    private let logger: Logger
    
    public init(client: any HTTPClient) {
        self.client = client
        self.logger = Logger(.coreApi)
    }

    @MainActor
    public convenience init(loader: HTTPLoader) {
        self.init(client: HTTPLoaderClient(loader: loader))
    }
    
    public func getPlaces() async throws -> ResourceCollection<Place> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/locations"
        )
        
        let result = await self.client.load(request)
        
        if let error = result.error {
            throw error
        }
        
        return try await result.decoding(ResourceCollection<Place>.self)
        
    }
    
    public func getPlace(placeID: Place.ID) async throws -> Place {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/locations/\(placeID)"
        )
        
        let result = await self.client.load(request)
        
        if let error = result.error {
            throw error
        }
        
        return try await result.decoding(Place.self)
        
    }
    
}
