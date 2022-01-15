//
//  DefaultParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Combine
import ModernNetworking

public class DefaultParkingService: ParkingService {
    
    private let loader: HTTPLoader
    
    public init(
        loader: HTTPLoader
    ) {
        self.loader = loader
    }
    
    public func loadParkingAreas() -> AnyPublisher<[ParkingArea], Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: ""
        )
        
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
}
