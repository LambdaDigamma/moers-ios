//
//  PlaceService.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import ModernNetworking

public protocol PlaceService {
    
    func getPlaces() async throws -> ResourceCollection<Place>
    
}
