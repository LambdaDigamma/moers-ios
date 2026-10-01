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
import FactoryKit
import EFAAPI
import ModernNetworking
import MapKit

@Observable
public class InTrainMapViewModel: StandardViewModel {
    
    public var currentSpeed: String?
    public var currentPlace: String?
    
    public var polyline: DataState<[MKPolyline], Error> = .loading
    public var points: DataState<[RouteStationAnnotation], Error> = .loading
    
    @ObservationIgnored @LazyInjected(\.geocodingService) var geocodingService
    @ObservationIgnored @LazyInjected(\.transitService) var transitService
    
    @ObservationIgnored
    private let locationObject: CoreLocationObject
    @ObservationIgnored
    private var locationTask: Task<Void, Never>?
    
    public init(locationObject: CoreLocationObject = CoreLocationObject()) {
        self.locationObject = locationObject
        super.init()
    }

    nonisolated deinit {
        locationTask?.cancel()
    }
    
    public func load() async {
        guard !Task.isCancelled else { return }
        do {
            let request = try await transitService.geoObject(lines: [
                "ddb:90E31: :R:j23",
                "ddb:90E33: :R:j23"
            ])

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

            guard !Task.isCancelled else { return }
            self.polyline = .success(polyline)
            self.points = .success(points)

        } catch {
            guard !Task.isCancelled else { return }
            self.polyline = .error(error)
            self.points = .error(error)
        }
    }


    public func start() {
        guard locationTask == nil else { return }
        
        locationObject
            .locationPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (location: CLLocation?) in
                
                if location?.speedAccuracy != nil, let speed = location?.speed, speed > 0 {
                    
                    if #available(iOS 15.0, *) {
                        
                        let measurement = Measurement(value: speed, unit: UnitSpeed.metersPerSecond)
                        self?.currentSpeed = "\(measurement.converted(to: .kilometersPerHour).formatted())"
                    }
                    
                }
                
            }
            .store(in: &cancellables)
        
        locationObject.beginUpdates(.authorizedWhenInUse)
        
        locationTask = Task { [weak self] in
            let timerStream = Timer.publish(every: 30, on: .main, in: .common)
                .autoconnect()
                .values

            for await _ in timerStream {
                guard !Task.isCancelled else { return }
                guard let location = self?.locationObject.location,
                      let geocodingService = self?.geocodingService else { continue }
                do {
                    let placemark = try await geocodingService.placemark(from: location)
                    guard !Task.isCancelled else { return }
                    self?.currentPlace = placemark.locality
                } catch {
                    guard !Task.isCancelled else { return }
                }
            }
        }
    }

    public func stop() {
        locationTask?.cancel()
        locationTask = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        locationObject.endUpdates()
        
    }
    
}
