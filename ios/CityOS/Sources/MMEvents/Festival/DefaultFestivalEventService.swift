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
import ModernNetworking
import FactoryKit

public class DefaultFestivalEventService: FestivalEventService {
    
    private let client: any HTTPClient
    
    public init(client: any HTTPClient) {
        self.client = client
    }

    @MainActor
    public convenience init(loader: HTTPLoader) {
        self.init(client: HTTPLoaderClient(loader: loader))
    }
    
    public func show(eventID: Event.ID, cacheMode: CacheMode) async throws -> FestivalEventPageResponse {
        
        var request = self.generateShowRequest(eventID: eventID)
        
        request.cachePolicy = cacheMode.policy
        
        let result = await client.load(request)
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
