//
//  StaticPetrolService.swift
//  
//
//  Created by Lennart Fischer on 19.12.21.
//

import Foundation
import CoreLocation
import Combine

public class StaticPetrolService: PetrolService {
    
    public var petrolType: PetrolType
    public var lastLoadLocation: CLLocation?
    
    public var loadPetrolStation: ((PetrolStation.ID) -> PetrolStation)
    public var loadPetrolStations: (() -> [PetrolStation])
    
    public init(
        petrolType: PetrolType = .diesel,
        lastLoadLocation: CLLocation? = nil,
        loadPetrolStation: @escaping ((PetrolStation.ID) -> PetrolStation),
        loadPetrolStations: @escaping (() -> [PetrolStation])
    ) {
        self.petrolType = petrolType
        self.lastLoadLocation = lastLoadLocation
        self.loadPetrolStation = loadPetrolStation
        self.loadPetrolStations = loadPetrolStations
    }
    
    public convenience init(
        petrolType: PetrolType = .diesel,
        lastLoadLocation: CLLocation? = nil
    ) {
        self.init(
            petrolType: .diesel,
            lastLoadLocation: nil
        ) { (id: PetrolStation.ID) in
            
            return PetrolStation(
                id: "094C38DD-87CD-4EE2-B8A8-86A05AD94CCD",
                name: "JET Tankstelle",
                brand: "JET",
                street: "Musterstraße",
                place: "Musterort",
                houseNumber: "1",
                postCode: 12345,
                lat: 51.45165,
                lng: 6.62628,
                dist: 2.34,
                diesel: 1.65, e5: 1.76, e10: 1.88,
                price: 1.65,
                isOpen: true,
                wholeDay: true,
                openingTimes: [PetrolStationTimeEntry.init(text: "Mo-So", start: "00:00", end: "23:59")],
                overrides: nil,
                state: nil
            )
            
        } loadPetrolStations: {
        
            return [
                .stub(withID: "10034A96-B228-4451-8793-451AB7CBD982"),
                .stub(withID: "9D164B7E-A20E-4A2A-8C85-914399003914"),
            ]
            
        }

    }
    
    public func getPetrolStations(
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        sorting: PetrolSorting,
        type: PetrolType,
        shouldReload: Bool
    ) -> AnyPublisher<[PetrolStation], Error> {
        
        let stations = loadPetrolStations()
        
        return Just(stations)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func getPetrolStation(
        id: PetrolStation.ID
    ) -> AnyPublisher<PetrolStation, Error> {
        
        let station = loadPetrolStation(id)
        
        return Just(station)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
}
