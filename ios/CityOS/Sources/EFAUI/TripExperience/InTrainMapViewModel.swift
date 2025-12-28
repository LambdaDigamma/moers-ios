//
//  InTrainMapViewModel.swift
//  
//
//  Created by Lennart Fischer on 27.12.22.
//

import SwiftUI
import Combine
import CoreLocation
import Core
import Factory
import EFAAPI
import ModernNetworking
import MapKit

public class InTrainMapViewModel: StandardViewModel {
    
    @Published public var currentSpeed: String?
    @Published public var currentPlace: String?
    
    @Published public var polyline: DataState<[MKPolyline], Error> = .loading
    @Published public var points: DataState<[RouteStationAnnotation], Error> = .loading
    
    @Injected(\.geocodingService) var geocodingService
    @Injected(\.transitService) var transitService
    
    private let locationObject = CoreLocationObject()
    
    public override init() {
        
    }
    
    public func load() {
        
        transitService.geoObject(lines: [
            "ddb:90E31: :R:j23",
            "ddb:90E33: :R:j23"
        ])
        .sink { (completion: Subscribers.Completion<HTTPError>) in
            
        } receiveValue: { (request: GeoITDRequest) in
            
            let polyline = request.geoObjectRequest.geoObject
                .geoObjectLineResponse
                .lineItemList
                .lineItems.map({ (lineItem: LineItem) in
                    return lineItem.toPolyline()
                })
                .reduce([], +)
            
            let points = request.geoObjectRequest.geoObject
                .geoObjectLineResponse
                .lineItemList.lineItems.map { (lineItem: LineItem) in
                    return lineItem.points.map { (point: ITDPoint) in
                        RouteStationAnnotation(name: point.name, coordinate: point.coordinate)
                    }
                }
                .reduce([], +)
            
            self.polyline = .success(polyline)
            self.points = .success(points)
            
        }
        .store(in: &cancellables)
        
    }
    
    public func start() {
        
        locationObject
            .$location
            .receive(on: DispatchQueue.main)
            .sink { (location: CLLocation?) in
                
                if let _ = location?.speedAccuracy, let speed = location?.speed, speed > 0 {
                    
                    if #available(iOS 15.0, *) {
                        
                        let measurement = Measurement(value: speed, unit: UnitSpeed.metersPerSecond)
                        self.currentSpeed = "\(measurement.converted(to: .kilometersPerHour).formatted())"
                    }
                    
                }
                
            }
            .store(in: &cancellables)
        
        locationObject.beginUpdates(.authorizedWhenInUse)
        
        Task {
            let timerStream = Timer.publish(every: 30, on: .main, in: .common)
                .autoconnect()
                .values
            
            for await _ in timerStream {
                do {
                    if let location = locationObject.location {
                        let placemark = try await geocodingService.placemark(from: location)
                        await MainActor.run {
                            self.currentPlace = placemark.locality
                        }
                    }
                } catch {
                    
                }
            }
        }
        
    }
    
    public func stop() {
        
        locationObject.endUpdates()
        
    }
    
}
