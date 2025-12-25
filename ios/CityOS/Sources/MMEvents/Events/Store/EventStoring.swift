//
//  EventStoring.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation

public protocol EventStoring {
    
    func fetch() async throws -> [Event]
    
    @discardableResult func insert(_ event: Event) async throws -> Event
    
    @discardableResult func delete(_ event: Event) async throws -> Bool
    
}
