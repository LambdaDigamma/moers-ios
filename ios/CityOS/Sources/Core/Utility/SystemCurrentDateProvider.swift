//
//  SystemCurrentDateProvider.swift
//  Core
//
//  Created by Codex on 16.05.26.
//

import Combine
import Foundation

public final class SystemCurrentDateProvider: CurrentDateProviding, @unchecked Sendable {
    
    public var now: Date {
        Date()
    }
    
    public let dateDidChange: AnyPublisher<Date, Never>
    
    public init(refreshInterval: TimeInterval = 1) {
        let refreshInterval = max(refreshInterval, 0.1)
        
        dateDidChange = Timer
            .publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }
    
}
