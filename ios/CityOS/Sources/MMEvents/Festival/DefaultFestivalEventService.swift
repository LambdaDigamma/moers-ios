//
//  DefaultFestivalEventService.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import Core
import Combine
import MMPages
import Foundation
import MediaLibraryKit
import ModernNetworking
import Factory

public class DefaultFestivalEventService: FestivalEventService {
    
    private let loader: HTTPLoader
    
    public init(loader: HTTPLoader) {
        self.loader = loader
    }
    
    public func show(eventID: Event.ID) -> AnyPublisher<FestivalEventPageResponse, Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/events/\(eventID)"
        )
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .compactMap { $0.body }
        .decode(type: Resource<FestivalEventPageResponse>.self, decoder: Event.decoder)
        .map({
            return $0.data
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    public func show(eventID: Event.ID, cacheMode: CacheMode) async throws -> FestivalEventPageResponse {
        
        var request = self.generateShowRequest(eventID: eventID)
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        let response = try await result.decoding(Resource<FestivalEventPageResponse>.self, using: Event.decoder)
        
        return response.data
        
    }
    
    private func generateShowRequest(eventID: Event.ID) -> HTTPRequest {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v1/festival/events/\(eventID)"
        )
        
        return request
        
    }
    
}
