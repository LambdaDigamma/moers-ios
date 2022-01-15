//
//  ParkingAreaList.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Core
import MapKit

public class ParkingAreaListViewModel: StandardViewModel {
    
    private let locationService: LocationService?
    
    @Published public var parkingAreas: [ParkingAreaViewModel] = []
    
    @Published public var filter: ParkingAreaFilterType = .all
    @Published public var userGrantedLocation: Bool = false
    @Published public var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CoreSettings.regionCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    
    public init(locationService: LocationService? = nil) {
        self.locationService = locationService
    }
    
    public func load() {
        
        if let locationService = locationService {
            
            let authorizationStatusAllowsFindingNearby = [
                CLAuthorizationStatus.authorizedAlways,
                CLAuthorizationStatus.authorizedAlways,
            ].contains(locationService.authorizationStatus.value)
            
            self.userGrantedLocation = authorizationStatusAllowsFindingNearby
            
        }
        
        self.parkingAreas = [
            .init(title: "Kauzstr.", free: 51, total: 62, currentOpeningState: .open),
            .init(title: "Bankstr.", free: 137, total: 139, currentOpeningState: .open),
            .init(title: "Kastell", free: 76, total: 200, currentOpeningState: .open),
            .init(title: "Mühlenstr.", free: 709, total: 709, currentOpeningState: .open),
        ]
        
    }
    
}
