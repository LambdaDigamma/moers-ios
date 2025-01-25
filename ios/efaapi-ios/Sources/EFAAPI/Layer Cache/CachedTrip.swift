//
//  CachedTrip.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation

public struct CachedEFATrip: Codable {
    
    public var request: CachedEfaTripRequest
    public var response: CachedEfaTripResponse
    
    public init(
        request: CachedEfaTripRequest,
        response: CachedEfaTripResponse
    ) {
        self.request = request
        self.response = response
    }
    
}

public struct CachedEfaTripRequest: Codable {
    
    public var tripDate: CachedTripDate
    public var origin: CachedEFAStation
    public var via: CachedEFAStation?
    public var destination: CachedEFAStation
    
    public init(
        tripDate: CachedTripDate,
        origin: CachedEFAStation,
        via: CachedEFAStation? = nil,
        destination: CachedEFAStation
    ) {
        self.tripDate = tripDate
        self.origin = origin
        self.via = via
        self.destination = destination
    }
    
}

public struct CachedEfaTripResponse: Codable {
    
    public var lines: [CachedPartialLine] = []
    
    public init(
        lines: [CachedPartialLine] = []
    ) {
        self.lines = lines
    }
    
}
