//
//  DefaultPetrolServiceTests.swift
//  
//
//  Created by Lennart Fischer on 18.12.21.
//

import Foundation
import XCTest
import Combine
import CoreLocation
@testable import FuelFeature

final class DefaultPetrolServiceTests: ServiceTestCase {
    
    func test_getStations() {
        
        let expectation = expectation(description: "Loading stations")
        let service = createService()
        
        service.getPetrolStations(
            coordinate: CLLocationCoordinate2D(
                latitude: 51.45165,
                longitude: 6.62628
            ),
            radius: 25,
            sorting: .distance,
            type: .diesel
        )
            .sink { (completion: Subscribers.Completion<Error>) in
                
                switch completion {
                    case .failure(let error):
                        print(error)
                        XCTFail("Loading failed")
                    default: break
                }
                
            } receiveValue: { (petrolStations: [PetrolStation]) in
                
                XCTAssert(!petrolStations.isEmpty)
                
                XCTAssertEqual(service.lastLoadLocation?.coordinate.latitude, 51.45165)
                XCTAssertEqual(service.lastLoadLocation?.coordinate.longitude, 6.62628)
                
                expectation.fulfill()
                
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func test_getStation() {
        
        let expectation = expectation(description: "Loading station")
        let service = createService()
        
        service.getPetrolStation(id: "78705b10-1ce8-40ff-8cb8-77d7fc5687cc")
            .sink { (completion: Subscribers.Completion<Error>) in
                
                switch completion {
                    case .failure(let error):
                        print(error)
                        XCTFail("Loading failed")
                    default: break
                }
                
            } receiveValue: { (petrolStation: PetrolStation) in
                
                XCTAssertEqual(petrolStation.id, "78705b10-1ce8-40ff-8cb8-77d7fc5687cc")
                
                expectation.fulfill()
                
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func createService() -> DefaultPetrolService {
        
        let apiKey = "0dfdfad3-7385-ef47-2ff6-ec0477872677"
        let service = DefaultPetrolService(apiKey: apiKey)
        
        return service
        
    }
    
}
