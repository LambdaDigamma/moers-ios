//
//  LocationEventService.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import Foundation
import ModernNetworking
import MMEvents
import OSLog

public protocol LocationEventService {
    
    func getLocations() async throws -> [Place]
    
    func showVenue(id: Place.ID) async throws -> Place
    
    func updateLocalFestivalArchive(force: Bool) async
    
}

public extension Notification.Name {
    
    static let updateFestivalGeoData = Notification.Name("updateFestivalGeoData")
    
}
