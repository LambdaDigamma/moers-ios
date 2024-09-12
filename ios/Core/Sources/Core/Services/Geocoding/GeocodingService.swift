//
//  GeocodingService.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import CoreLocation
import Combine

public protocol GeocodingService {
    
    func placemark(from location: CLLocation) -> AnyPublisher<CLPlacemark, Error>
    
}
