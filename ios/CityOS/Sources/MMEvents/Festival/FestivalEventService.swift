//
//  FestivalEventService.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import Combine
import MMPages
import Foundation
import MediaLibraryKit
import ModernNetworking

public protocol FestivalEventService {
    
    func show(eventID: Event.ID) -> AnyPublisher<FestivalEventPageResponse, Error>
    
    func show(eventID: Event.ID, cacheMode: CacheMode) async throws -> FestivalEventPageResponse
    
}
