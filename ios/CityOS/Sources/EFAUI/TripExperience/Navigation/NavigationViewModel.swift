//
//  NavigationViewModel.swift
//  
//
//  Created by Lennart Fischer on 25.12.22.
//

import Foundation
import MapKit
import Core
import Observation

@MainActor
@Observable
public class NavigationViewModel {
    
    public var source: Point
    public var destination: Point
    public var directionsMode = DirectionsMode.walking
    
    public var directions: DataState<MKDirections.Response, Error> = .loading
    
    public init(
        source: Point,
        destination: Point,
        directionsMode: DirectionsMode = DirectionsMode.walking
    ) {
        self.source = source
        self.destination = destination
        self.directionsMode = directionsMode
    }
    
    public func calculateDirections(
        from source: Point,
        to destination: Point,
        directionsMode: DirectionsMode = .walking
    ) async throws -> MKDirections.Response {
        
        let request = MKDirections.Request()
        
        request.transportType = directionsMode.toDirectionsTransportType()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.toCoordinate()))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.toCoordinate()))
        
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        
        return response
        
    }
    
    public func load() async {

        do {
            let response = try await self.calculateDirections(from: source, to: destination)
            self.directions = .success(response)
        } catch {
            self.directions = .error(error)
        }

    }
    
}
