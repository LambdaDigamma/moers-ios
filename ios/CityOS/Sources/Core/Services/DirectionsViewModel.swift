//
//  DirectionsViewModel.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import Foundation
import MapKit
import Combine
import OSLog
import SwiftUI
import Factory

public class DirectionsViewModel: StandardViewModel {
    
    @Published public var eta: DataState<TimeInterval, Error> = .loading
    @Published public var directionsMode: DirectionsMode = .driving
    
    private let logger = Logger(.default)
    
    private let locationService: LocationService
    
    @Injected(\.locationService) private var locationServiceFactory: LocationService
    
    public init(
        locationService: LocationService? = nil,
        directionsMode: DirectionsMode = .driving
    ) {
        self.locationService = locationService ?? locationServiceFactory
        self.directionsMode = directionsMode
    }
    
    public func getETA(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) {
        
        ETACalculator.execute(
            from: source,
            to: destination,
            with: directionsMode
        )
            .sink { (completion: Subscribers.Completion<Error>) in
            
                switch completion {
                    case .failure(let error):
                        self.logger.error("Error while getting eta: \(error.localizedDescription, privacy: .public)")
                        self.eta = .error(error)
                    default: break
                }
                
            } receiveValue: { (timeInterval: TimeInterval) in
                self.logger.log("Received eta and it would take \(timeInterval) seconds to get there.")
                self.eta = .success(timeInterval)
            }
            .store(in: &cancellables)

    }
    
    public func getETAFromUserLocation(to destination: CLLocationCoordinate2D) {
        
        locationPublisher()
            .flatMap { (userLocation: CLLocation) -> AnyPublisher<TimeInterval, Error> in
                return ETACalculator.execute(
                    from: userLocation.coordinate,
                    to: destination,
                    with: self.directionsMode
                )
            }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                switch completion {
                    case .failure(let error):
                        self.logger.error("Error while getting eta: \(error.localizedDescription, privacy: .public)")
                        self.eta = .error(error)
                    default: break
                }
            } receiveValue: { (eta: TimeInterval) in
                self.logger.log("Received eta and it would take \(eta) seconds to get there.")
                self.eta = .success(eta)
                print(self.eta)
            }
            .store(in: &cancellables)
        
    }
    
    private func locationPublisher() -> AnyPublisher<CLLocation, Never> {
        return locationService
            .location
            .replaceError(with: CoreSettings.regionLocation)
            .filter({ $0.coordinate.latitude != 0.0 && $0.coordinate.longitude != 0.0 })
            .prefix(1)
            .eraseToAnyPublisher()
    }
    
}

public class ETACalculator {
    
    public static func execute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        with directionsMode: DirectionsMode = .driving
    ) -> AnyPublisher<TimeInterval, Error> {
        
        return Deferred {
            return Future { promise in
                
                let source = MKMapItem(placemark: MKPlacemark(coordinate: source))
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
                
                let request = MKDirections.Request()
                
                request.source = source
                request.destination = destination
                request.transportType = directionsMode.toDirectionsTransportType()
                
                let directions = MKDirections(request: request)
                
                directions.calculateETA { (response: MKDirections.ETAResponse?, error: Error?) in
                    
                    if let error = error {
                        promise(.failure(error))
                    }
                    
                    if let response = response {
                        promise(.success(response.expectedTravelTime))
                    }
                    
                }
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
}
