//
//  StaticPlaceService.swift
//  
//
//  Created by Lennart Fischer on 13.04.23.
//

import Foundation
import Combine
import ModernNetworking

public class StaticPlaceService: PlaceService {
    
    private let places: Result<[Place], Error>
    
    public init(places: Result<[Place], Error>) {
        self.places = places
    }
    
    public func getPlaces() async throws -> ResourceCollection<Place> {
        
        switch places {
            case .success(let success):
                return ResourceCollection(data: success, links: .init(), meta: .init())
            case .failure(let failure):
                throw failure
        }
        
    }
    
    public func getPlaces() -> AnyPublisher<[Place], Error> {
        
        switch places {
            case .success(let success):
                return Just(success)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            case .failure(let failure):
                return Fail(error: failure)
                    .eraseToAnyPublisher()
        }
        
    }
    
}
