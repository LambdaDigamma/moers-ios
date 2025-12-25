//
//  RouteUiState.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Foundation

public struct RouteUiState: Codable, Equatable, Hashable {
    
    public let origin: String
    public let destination: String
    public let date: Date
    public let duration: String
    public let numberOfChanges: Int
    
    public var partialRoutes: [PartialRouteUiState]
    
    public init(
        origin: String,
        destination: String,
        date: Date,
        duration: String,
        numberOfChanges: Int,
        partialRoutes: [PartialRouteUiState]
    ) {
        self.origin = origin
        self.destination = destination
        self.date = date
        self.duration = duration
        self.numberOfChanges = numberOfChanges
        self.partialRoutes = partialRoutes
    }
    
}

public protocol RouteDetailPresentable {
    
    func transformIntoUiState(origin: String, destination: String) -> RouteUiState
    
}

extension ITDRoute: RouteDetailPresentable {
    
    public func transformIntoUiState(origin: String, destination: String) -> RouteUiState {
        
        let partialRoutes = self.partialRouteList
            .partialRoutes
            .compactMap({ (partialRoute: ITDPartialRoute) -> PartialRouteUiState? in
                
                guard let from = partialRoute.points.first?.transformToPoint(),
                        let to = partialRoute.points.last?.transformToPoint() else {
                    return nil
                }
                
                return PartialRouteUiState(
                    transportType: partialRoute.meansOfTransport.motType.toUiType(),
                    from: from,
                    to: to,
                    timeInMinutes: partialRoute.timeMinute,
                    distance: partialRoute.distance ?? 0,
                    line: partialRoute.meansOfTransport.symbol,
                    lineDestination: partialRoute.meansOfTransport.destination,
                    footPathAfter: partialRoute.footPathInfo != nil ? FootPathRouteUiState(
                        text: String(describing: partialRoute.footPathInfo)
                    ) : nil
                )
                
            })
        
        return RouteUiState(
            origin: origin,
            destination: destination,
            date: self.targetStartDate ?? Date(),
            duration: self.publicDuration,
            numberOfChanges: self.numberOfChanges,
            partialRoutes: partialRoutes
        )
        
    }
    
}

extension ITDPoint {
    
    func transformToPoint() -> PartialRouteUiState.Point {
        
        return PartialRouteUiState.Point(
            stationName: self.name,
            targetDate: self.targetDateTime?.parsedDate ?? Date(),
            realtimeDate: self.dateTime.parsedDate ?? nil,
            platform: self.platformName
        )
        
    }
    
}
