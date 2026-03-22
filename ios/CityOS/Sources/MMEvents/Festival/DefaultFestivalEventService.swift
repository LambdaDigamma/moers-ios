//
//  DefaultFestivalEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Core
import MMPages
import Foundation
import MediaLibraryKit
@preconcurrency import ModernNetworking
import Factory

public class DefaultFestivalEventService: FestivalEventService {
    
    nonisolated(unsafe) private let loader: HTTPLoader
    
    public init(loader: HTTPLoader) {
        self.loader = loader
    }
    
    @concurrent
    public nonisolated func show(eventID: Event.ID, cacheMode: CacheMode) async throws -> FestivalEventPageResponse {
        
        var request = self.generateShowRequest(eventID: eventID)
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        let response = try await result.decoding(Resource<FestivalEventPageResponse>.self, using: Event.decoder)
        
        return response.data
        
    }
    
    private nonisolated func generateShowRequest(eventID: Event.ID) -> HTTPRequest {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/events/\(eventID)/page"
        )
        
        return request
        
    }
    
}