//
//  ParkingAreaList.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Core
import MapKit
import Combine

public class ParkingAreaListViewModel: StandardViewModel {
    
    private let parkingService: ParkingService
    private let locationService: LocationService?
    
    @Published public var parkingAreas: [ParkingAreaViewModel] = []
    @Published public var filteredParkingAreas: [ParkingAreaViewModel] = []
    @Published public var filter: ParkingAreaFilterType = .all
    @Published public var userGrantedLocation: Bool = false
    @Published public var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CoreSettings.regionCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    
    public var mapViewModel = BaseMapViewModel()
    
    public init(
        parkingService: ParkingService,
        locationService: LocationService? = nil
    ) {
        self.parkingService = parkingService
        self.locationService = locationService
        
        self.mapViewModel.register(
            view: ParkingAreaAnnotationView.self,
            reuseIdentifier: ParkingAreaAnnotationView.reuseIdentifier
        )
        
        self.mapViewModel.configureView = { (mapView: MKMapView, annotation: MKAnnotation) in
            
            if let parkingArea = annotation as? ParkingAreaAnnotation {
                return mapView.dequeueReusableAnnotationView(
                    withIdentifier: ParkingAreaAnnotationView.reuseIdentifier,
                    for: parkingArea
                )
            }
            
            return nil
        }
        
        super.init()
        
        self.setupListeners()
    }
    
    public func load() {
        
        if let locationService = locationService {
            
            let authorizationStatusAllowsFindingNearby = [
                CLAuthorizationStatus.authorizedAlways,
                CLAuthorizationStatus.authorizedAlways,
            ].contains(locationService.authorizationStatus.value)
            
            self.userGrantedLocation = authorizationStatusAllowsFindingNearby
            
        }
        
        parkingService.loadParkingAreas()
            .sink { (_: Subscribers.Completion<Error>) in
                
            } receiveValue: { (parkingAreas: [ParkingArea]) in
                
                self.parkingAreas = parkingAreas.map({ ParkingAreaViewModel(
                    title: $0.name,
                    free: $0.freeSites,
                    total: $0.capacity ?? 0,
                    location: $0.location,
                    currentOpeningState: $0.currentOpeningState,
                    updatedAt: $0.updatedAt ?? Date()
                )})
                
                self.updateFilter(filter: self.filter)
                
                self.mapViewModel.annotations = parkingAreas.compactMap {
                    guard let coordinate = $0.location?.toCoordinate() else { return nil }
                    return ParkingAreaAnnotation(coordinate: coordinate, title: $0.name)
                }
                
            }
            .store(in: &cancellables)
        
    }
    
    private func setupListeners() {
        
        $filter.sink { [weak self] (filter: ParkingAreaFilterType) in
            self?.updateFilter(filter: filter)
        }
        .store(in: &cancellables)
        
    }
    
    private func updateFilter(filter: ParkingAreaFilterType) {
        
        if filter == .all {
            self.filteredParkingAreas = parkingAreas
        } else {
            self.filteredParkingAreas = parkingAreas.filter { $0.currentOpeningState == .open }
        }
        
    }
    
}
