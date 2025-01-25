//
//  PartialRouteUiState.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation

public struct PartialRouteUiState: Codable, Equatable, Hashable, Identifiable {
    
    public var id = UUID()
    public let transportType: TransportTypeUi
    public let from: Point
    public let to: Point
    public let timeInMinutes: Int
    public let line: String
    public let lineDestination: String
    
    public let footPathAfter: FootPathRouteUiState?
    
    /// Distance in meters
    public let distance: Int?
    
    public init(
        id: UUID = UUID(),
        transportType: TransportTypeUi,
        from: Point,
        to: Point,
        timeInMinutes: Int,
        distance: Int?,
        line: String,
        lineDestination: String,
        footPathAfter: FootPathRouteUiState? = nil
    ) {
        self.id = id
        self.transportType = transportType
        self.from = from
        self.to = to
        self.timeInMinutes = timeInMinutes
        self.distance = distance
        self.line = line
        self.lineDestination = lineDestination
        self.footPathAfter = footPathAfter
    }
    
    public struct Point: Codable, Equatable, Hashable {
        public let stationName: String
        public let targetDate: Date
        public let realtimeDate: Date?
        public let platform: String
        
        public init(stationName: String, targetDate: Date, realtimeDate: Date?, platform: String) {
            self.stationName = stationName
            self.targetDate = targetDate
            self.realtimeDate = realtimeDate
            self.platform = platform
        }
        
    }
    
    var targetDuration: DateInterval {
        return DateInterval(start: from.targetDate, end: to.targetDate)
    }
    
    var realtimeDuration: DateInterval {
        let start = from.realtimeDate ?? from.targetDate
        let end = to.realtimeDate ?? to.targetDate
        return DateInterval(start: start, end: end)
    }
    
}
