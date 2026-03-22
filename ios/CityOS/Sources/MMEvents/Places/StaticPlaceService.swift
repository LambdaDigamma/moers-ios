//
//  StaticPlaceService.swift
//  
//
//  Created by Lennart Fischer on 13.04.23.
//

import Foundation
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
    
}