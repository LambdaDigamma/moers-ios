//
//  ActiveTripViewModel.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import SwiftUI
import CoreLocation
import Combine
import Core
import Factory
import EFAAPI
import ModernNetworking

public struct ActiveTripData {
    
    public let response: CachedEfaTripResponse
    
    public let raw: TripRequest
    
}

public class ActiveTripViewModel: StandardViewModel {
    
    @LazyInjected(\.tripService) var tripService
    @LazyInjected(\.transitService) var transitService
    
    public var search = TripSearchViewModel()
    
    @Published public var trip: DataState<ActiveTripData, Error> = .loading
    
    public override init() {
        
    }
    
    /// Loads the cached trip from the trip manager
    /// and populates the `TripSearchViewModel`.
    public func load() {
        
        self.loadFromCache()
        
    }
    
    private func loadFromCache() {
        
        guard let trip = tripService.currentTrip else { return }
        
        let request = trip.request
        
        search.originID = request.origin.id
        search.destinationID = request.destination.id
        
        search.origin = .init(
            stationID: nil,
            statelessIdentifier: request.origin.id,
            locationType: .location,
            name: request.origin.name,
            description: "",
            coordinates: request.origin.coordinates?.toCoordinate()
        )
        
        search.destination = .init(
            stationID: nil,
            statelessIdentifier: request.destination.id,
            locationType: .location,
            name: request.destination.name,
            description: "",
            coordinates: request.destination.coordinates?.toCoordinate()
        )
        
        self.reloadTrip(trip: trip)
        
    }
    
    private func reloadTrip(trip: CachedEFATrip) {
        
        var dateTimeType: TripDateTimeType = .departure
        
        if case .arrival = dateTimeType {
            dateTimeType = .arrival
        }
        
        transitService.sendTripRequest(
            origin: trip.request.origin.id,
            destination: trip.request.destination.id,
            config: .init(),
            tripDate: trip.request.tripDate.toExperience()
        )
        .sink { (error: Subscribers.Completion<HTTPError>) in
            
            switch error {
                case .failure(let error):
                    self.trip = .error(error)
                    
                default: break
            }
            
        } receiveValue: { (response: TripResponse) in
            
            self.trip = .success(.init(
                response: trip.response,
                raw: response.tripRequest
            ))
            
//            response.tripRequest.itinerary.routeList
            
        }
        .store(in: &cancellables)
        
    }
    
    /// Terminates the active trip and removes all cached data.
    public func terminate() {
        tripService.resetTrip()
    }
    
}
