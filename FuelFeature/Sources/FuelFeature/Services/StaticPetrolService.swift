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
                .stub(withID: "10034A96-B228-4451-8793-451AB7CBD982")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.56),
                .stub(withID: "9D164B7E-A20E-4A2A-8C85-914399003914")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.58),
                .stub(withID: "5A7150D9-E860-46F0-9826-61F179D22B7F")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.61),
                .stub(withID: "BDE795B8-BF6C-4F02-8419-EA6C4E472031")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.56),
                .stub(withID: "C4016598-6159-44DD-AB6B-1BC1EA40B8F9")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.58),
                .stub(withID: "C8148712-6889-4F29-87D3-EFA06EF3B851")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.61),
                .stub(withID: "76036FF8-32B8-49A9-A4BB-563A01557038")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.56),
                .stub(withID: "72DB3FFD-0A62-4B75-9DFD-6D385BF8FA03")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.58),
                .stub(withID: "DE2E0E6A-5980-4486-AC85-274845B4CD56")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.61),
                .stub(withID: "971A3F1C-CB6E-4FD6-983F-E6E6F673B423")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.56),
                .stub(withID: "F9564C89-3171-4728-B4F6-92E59D756402")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.58),
                .stub(withID: "9E7BCE23-4CBB-4859-820F-2FF46DCA1621")
                    .setting(\.isOpen, to: true)
                    .setting(\.price, to: 1.61),
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
