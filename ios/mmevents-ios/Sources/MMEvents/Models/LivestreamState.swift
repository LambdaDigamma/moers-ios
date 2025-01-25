//
//  LivestreamState.swift
//  
//
//  Created by Lennart Fischer on 04.05.21.
//

import Foundation

public typealias ActiveStream = (streamURL: URL, activeEvent: Event?)

public enum LivestreamState: Equatable {
    case loading
    case countdown(startDate: Date)
    case activeStream(livestreamData: LivestreamData)
    case inactiveStream
}
