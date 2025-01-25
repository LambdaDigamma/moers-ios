//
//  TripSearchViewModel.swift
//  
//
//  Created by Lennart Fischer on 05.04.22.
//

import Foundation
import EFAAPI
import ModernNetworking
import Combine
import OSLog
import Factory
import CoreLocation

public class TripSearchViewModel: ObservableObject {
    
    @Published public var originID: StatelessIdentifier?
    @Published public var destinationID: StatelessIdentifier?
    
    @Published public var origin: TransitLocation?
    @Published public var destination: TransitLocation?
    
    @Published var result: DataState<TripRequest, Error> = .empty
    
    public var onSearchEvent: (() -> Void)?
    
    private let transitService: TransitService
    private let tripService: DefaultTripService = Container.shared.tripService()
    private var cancellables = Set<AnyCancellable>()
    private let logger: Logger = .init(.default)
    
    public init(
        transitService: DefaultTransitService,
        originID: StatelessIdentifier? = nil,
        destinationID: StatelessIdentifier? = nil
    ) {
        self.transitService = transitService
        self.originID = originID
        self.destinationID = destinationID
    }
    
    public init(
        originID: StatelessIdentifier? = nil,
        destinationID: StatelessIdentifier? = nil
    ) {
        self.originID = originID
        self.destinationID = destinationID
        self.transitService = Container.shared.transitService()
    }
    
    public func updateOrigin(_ origin: TransitLocation) {
        self.originID = origin.statelessIdentifier
        self.origin = origin
        if let originID = originID {
            self.logger.info("User updated origin to station: \(originID)")
        }
    }
    
    public func updateDestination(_ destination: TransitLocation) {
        self.destinationID = destination.statelessIdentifier
        self.destination = destination
        if let destinationID = destinationID {
            self.logger.info("User updated destination to station: \(destinationID)")
        }
    }
    
    public func search() {
        
        guard let originID = originID, let destinationID = destinationID else {
            return
        }
        
        self.result = .loading
        
        transitService.sendTripRequest(
            origin: originID,
            destination: destinationID,
            config: .init(),
            tripDate: .departure(Date().addingTimeInterval(5 * 60 * 60))
        )
            .sink { (completion: Subscribers.Completion<HTTPError>) in
                
                switch completion {
                    case .failure(let error):
                        
                        print(error.underlyingError ?? "")
                        
                        self.result = .error(error)
                    default: break
                }
                
            } receiveValue: { [weak self] (response: TripResponse) in
                
                if self?.origin == nil, let nameElement = response.tripRequest.odv.origin?.name?.elements?.first {
                    self?.origin = .init(odvNameElement: nameElement)
                }
                
                if self?.destination == nil, let nameElement = response.tripRequest.odv.destination?.name?.elements?.first {
                    self?.destination = .init(odvNameElement: nameElement)
                }
                
                self?.result = .success(response.tripRequest)
                
            }
            .store(in: &cancellables)
        
    }
    
    public func swapOriginDestination() {
        
        let originDestinationIDs = (originID: originID, destinationID: destinationID)
        let originDestination = (origin: origin, destination: destination)
        
        self.originID = originDestinationIDs.destinationID
        self.destinationID = originDestinationIDs.originID
        
        self.origin = originDestination.destination
        self.destination = originDestination.origin
        
    }
    
    public func activate(route: ITDRoute, for tripRequest: TripRequest) {
        
        guard let origin = origin, let destination = destination else { return }
        
        let request = CachedEfaTripRequest(
            tripDate: tripRequest.tripDateTime.toCached(),
            origin: origin.toCached(),
            destination: destination.toCached()
        )
        
        let partialLines = route.partialRouteList.partialRoutes.compactMap { (partialRoute: ITDPartialRoute) -> CachedPartialLine? in
            
            guard let departure = partialRoute.points.usageDeparture, let arrival = partialRoute.points.usageArrival else {
                return nil
            }
            
            return CachedPartialLine(
                id: partialRoute.meansOfTransport.lineIdentifier,
                origin: departure.toCached(),
                destination: arrival.toCached(),
                plannedDeparture: Date(),
                plannedArrival: Date()
            )
        }
        
        let response = CachedEfaTripResponse(
            lines: partialLines
        )
        
        let cachedTrip = CachedEFATrip(
            request: request,
            response: response
        )
        
        tripService.activate(trip: cachedTrip)
        
    }
    
}

public extension TransitLocation {
    
    func toCached() -> CachedEFAStation {
        
        return CachedEFAStation(
            id: self.statelessIdentifier,
            name: self.name,
            coordinates: self.coordinates?.toPoint()
        )
        
    }
    
}

public extension ITDPoint {
    
    func toCached() -> CachedEFAStation {
        
        return CachedEFAStation(
            id: "\(self.stopID)",
            name: self.name,
            coordinates: CLLocationCoordinate2D(latitude: self.y, longitude: self.x).toPoint()
        )
        
    }
    
}

public extension ITDTripDateTime {
    
    func toCached() -> CachedTripDate {
        
        switch self.depArrType {
            case .arrival:
                let date = self.dateTime.parsedDate ?? Date()
                return .arrival(date)
            case .departure:
                let date = self.dateTime.parsedDate ?? Date()
                return .departure(date)
        }
        
    }
    
}
