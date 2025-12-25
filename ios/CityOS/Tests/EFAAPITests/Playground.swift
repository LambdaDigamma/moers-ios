//
//  Playground.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import Foundation
import XCTest
import Combine
import ModernNetworking
@testable import EFAAPI

final class Playground: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func testPlayground() {
        
        let expectation = XCTestExpectation()
        let loader = DefaultTransitService.defaultLoader()
        let service = DefaultTransitService(loader: loader)
        
        service.findTransitLocation(for: "Moers Bahnhof", filtering: [.noFilter])
//            .flatMap({ (locations: [TransitLocation]) in
//
//                if let location = locations.first {
//                    service.sendTripRequest()
//                }
//
//            })
//            .eraseToAnyPublisher()
            .sink { (completion: Subscribers.Completion<HTTPError>) in
                switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                }
            } receiveValue: { (locations: [TransitLocation]) in
                print(locations)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
        
    }
    
}
