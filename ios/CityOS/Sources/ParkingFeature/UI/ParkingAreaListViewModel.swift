//
//  ParkingAreaList.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Core
import MapKit

@MainActor
public class ParkingAreaListViewModel: StandardViewModel {
    
    private let parkingService: ParkingService
    private let locationService: LocationService?
    
    @Published public var parkingAreas: [ParkingAreaViewModel] = []
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
    
}
