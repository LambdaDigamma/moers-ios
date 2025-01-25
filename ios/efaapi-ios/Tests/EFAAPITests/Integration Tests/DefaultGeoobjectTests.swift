//
//  DefaultGeoobjectTests.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import XCTest
import Combine
import ModernNetworking
@testable import EFAAPI

final class DefaultGeoobjectTests: IntegrationTestCase {
    
    func test_basic_request() {
        
        let expectation = XCTestExpectation()
        
        let httpLoader = defaultLoader()
        let service = DefaultTransitService(loader: httpLoader)
        
        let line: StatelessLineIdentifier = "ddb:90E31: :R:j23"
        
        service
            .geoObject(lines: [line])
            .sink { (completion: Subscribers.Completion<HTTPError>) in
                
                switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        print(failure)
                }
                
            } receiveValue: { (response: GeoITDRequest) in
                
                XCTAssertEqual(response.language.count, 2)
                
                print(response.geoObjectRequest)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        
        wait(for: [expectation], timeout: 10)
        
    }
    
}
