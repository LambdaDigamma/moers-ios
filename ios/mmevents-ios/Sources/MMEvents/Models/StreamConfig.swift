//
//  StreamConfig.swift
//  
//
//  Created by Lennart Fischer on 04.05.21.
//

import Foundation
import ModernNetworking

public struct StreamConfig: Model, Equatable {
    
    public var streamURL: String?
    public var startDate: Date?
    public var failureTitle: String?
    public var failureDescription: String?
    public var events: [Event]
    
    public init(
        streamURL: String? = nil,
        startDate: Date? = nil,
        failureTitle: String? = nil,
        failureDescription: String? = nil,
        events: [Event] = []
    ) {
        self.streamURL = streamURL
        self.startDate = startDate
        self.failureTitle = failureTitle
        self.failureDescription = failureDescription
        self.events = events
    }
    
    enum CodingKeys: String, CodingKey {
        case streamURL = "url"
        case startDate = "start_date"
        case failureTitle = "failure_title"
        case failureDescription = "failure_description"
        case events = "events"
    }
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }
    
    public var processedStreamURL: URL? {
        return URL(string: streamURL ?? "")
    }
    
    public var shouldShowCountdown: Bool {
        
        if let startDate = startDate {
            return Date() < startDate
        } else {
            return true
        }
        
    }
    
}
