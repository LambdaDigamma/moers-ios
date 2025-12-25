//
//  PetrolService.swift
//  
//
//  Created by Lennart Fischer on 15.12.21.
//

import Foundation
import CoreLocation
import Combine

public protocol PetrolService {
    
    var petrolType: PetrolType { get set }
    
    var lastLoadLocation: CLLocation? { get set }
    
    func getPetrolStations(
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        sorting: PetrolSorting,
        type: PetrolType,
        shouldReload: Bool
    ) -> AnyPublisher<[PetrolStation], Error>
    
    func getPetrolStation(
        id: PetrolStation.ID
    ) -> AnyPublisher<PetrolStation, Error>
    
}
