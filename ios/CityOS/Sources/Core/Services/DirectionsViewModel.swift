//
//  DirectionsViewModel.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import Foundation
import MapKit
import OSLog
import SwiftUI
import Factory

public class DirectionsViewModel: StandardViewModel {
    
    @Published public var eta: DataState<TimeInterval, Error> = .loading
    @Published public var directionsMode: DirectionsMode = .driving
    
    private let logger = Logger(.default)
    
    @LazyInjected(\.locationService) private var locationService: LocationService
    
    public init(
        directionsMode: DirectionsMode = .driving
    ) {
        self.directionsMode = directionsMode
    }
    
    public func getETA(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async {
        do {
            let timeInterval = try await ETACalculator.execute(
                from: source,
                to: destination,
                with: directionsMode
            )
            
            logger.log("Received eta and it would take \(timeInterval) seconds to get there.")
            await MainActor.run {
                self.eta = .success(timeInterval)
            }
        } catch {
            logger.error("Error while getting eta: \(error.localizedDescription, privacy: .public)")
            await MainActor.run {
                self.eta = .error(error)
            }
        }
    }
    
    public func getETAFromUserLocation(to destination: CLLocationCoordinate2D) async {
        do {
            guard let userLocation = await waitForValidLocation() else {
                return
            }
            
            let timeInterval = try await ETACalculator.execute(
                from: userLocation.coordinate,
                to: destination,
                with: directionsMode
            )
            
            logger.log("Received eta and it would take \(timeInterval) seconds to get there.")
            await MainActor.run {
                self.eta = .success(timeInterval)
            }
        } catch {
            logger.error("Error while getting eta: \(error.localizedDescription, privacy: .public)")
            await MainActor.run {
                self.eta = .error(error)
            }
        }
    }
    
    private func waitForValidLocation() async -> CLLocation? {
        do {
            for try await location in locationService.locations {
                if location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0 {
                    return location
                }
            }
        } catch {
            return CoreSettings.regionLocation
        }
        return nil
    }
    
}

public class ETACalculator {
    
    public static func execute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        with directionsMode: DirectionsMode = .driving
    ) async throws -> TimeInterval {
        
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: source))
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = directionsMode.toDirectionsTransportType()
        
        let directions = MKDirections(request: request)
        
        let response = try await directions.calculateETA()
        return response.expectedTravelTime
    }
    
}

enum DirectionsError: Error {
    case noResponse
}
