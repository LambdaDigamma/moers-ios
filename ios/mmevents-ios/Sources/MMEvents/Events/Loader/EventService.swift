//
//  EventService.swift
//  
//
//  Created by Lennart Fischer on 13.04.23.
//

import Foundation
import ModernNetworking

public protocol EventService {
    
    func index(cacheMode: CacheMode, withPages: Bool) async throws -> ResourceCollection<Event>
    
    func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event>
    
}
