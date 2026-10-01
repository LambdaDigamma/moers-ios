//
//  ParkingAreaList.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Core
import MapKit
import Observation

@MainActor
@Observable
public class ParkingAreaListViewModel: StandardViewModel {
    
    private let parkingService: ParkingService
    private let locationService: LocationService?
    
    public var parkingAreas: [ParkingAreaViewModel] = []
    public var filter: ParkingAreaFilterType = .all
    public var userGrantedLocation: Bool = false
    public var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CoreSettings.regionCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    public var selectedParkingArea: ParkingAreaViewModel?
    
    public var mapViewModel: BaseMapViewModel
    
    public init(
        parkingService: ParkingService,
        locationService: LocationService? = nil
    ) {
        self.parkingService = parkingService
        self.locationService = locationService
        
        let mapViewModel = BaseMapViewModel()
        
        mapViewModel.register(
            view: ParkingAreaAnnotationView.self,
            reuseIdentifier: ParkingAreaAnnotationView.reuseIdentifier
        )
        
        mapViewModel.configureView = { (mapView: MKMapView, annotation: MKAnnotation) in
            
            if let parkingArea = annotation as? ParkingAreaAnnotation {
                return mapView.dequeueReusableAnnotationView(
                    withIdentifier: ParkingAreaAnnotationView.reuseIdentifier,
                    for: parkingArea
                )
            }
            
            return nil
        }
        
        self.mapViewModel = mapViewModel
        
        super.init()
        
        self.mapViewModel.onAnnotationSelected = { [weak self] annotation in
            guard let self = self,
                  let parkingAnnotation = annotation as? ParkingAreaAnnotation,
                  let parkingArea = self.parkingAreas.first(where: {
                      $0.title == parkingAnnotation.title
                  }) else {
                return
            }
            self.selectedParkingArea = parkingArea
        }
        
    }
    
    public func load() async {
        if let locationService = locationService {
            var hasAuthorizedStatus = false
            
            for await authorizationStatus in locationService.authorizationStatuses {
                let authorizationStatusAllowsFindingNearby = [
                    CLAuthorizationStatus.authorizedAlways,
                    CLAuthorizationStatus.authorizedWhenInUse,
                ].contains(authorizationStatus)
                
                hasAuthorizedStatus = authorizationStatusAllowsFindingNearby
                break
            }
            
            self.userGrantedLocation = hasAuthorizedStatus
        }
        
        do {
            let parkingAreas = try await parkingService.loadParkingAreas()
            
            self.parkingAreas = parkingAreas.map({ ParkingAreaViewModel(
                title: $0.name,
                free: $0.freeSites,
                total: $0.capacity ?? 0,
                location: $0.location,
                currentOpeningState: $0.currentOpeningState,
                updatedAt: $0.updatedAt ?? Date()
            )})
            
            self.mapViewModel.annotations = parkingAreas.compactMap {
                guard let coordinate = $0.location?.toCoordinate() else { return nil }
                return ParkingAreaAnnotation(coordinate: coordinate, title: $0.name)
            }
        } catch {
            print("Failed to load parking areas: \(error)")
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
