//
//  DefaultDepartureMonitorTests.swift
//  
//
//  Created by Lennart Fischer on 18.04.21.
//

import XCTest
import Combine
import ModernNetworking
@testable import EFAAPI

final class DefaultDepartureMonitorTests: IntegrationTestCase {
    
    func test_departureMonitorRequest() {
        
        let expectation = XCTestExpectation()
        
        let loader = defaultLoader()
        let service = DefaultTransitService(loader: loader)
        let request = service.sendRawDepartureMonitorRequest(id: 20016032)
        
        request.sink { (completion: Subscribers.Completion<HTTPError>) in
            switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
            }
        } receiveValue: { (response: DepartureMonitorResponse) in
            
            print(response.departureMonitorRequest)
            
        }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        
    }
    
}
