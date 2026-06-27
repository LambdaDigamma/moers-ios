//
//  DepartureViewModel.swift
//  
//
//  Created by Lennart Fischer on 08.12.21.
//

import SwiftUI

@Observable
public class DepartureViewModel: Identifiable{
    
    public let id: UUID = UUID()
    private let model: ITDDeparture
    
    public var description: String
    public var time: Date?
    public var actual: Date?
    public var transportType: TransportType
    public var platform: String?
    public var direction: String = ""
    public var symbol: String
    
    public init(departure: ITDDeparture) {
        self.model = departure
        self.time = departure.regularDateTime.parsedDate
        self.actual = departure.actualDateTime?.parsedDate
        self.description = departure.servingLine.descriptionText
        self.transportType = departure.servingLine.transportType
        self.direction = departure.servingLine.direction
        self.symbol = departure.servingLine.symbol
        let platform = departure.platformName ?? departure.platform
        
        if !platform.isEmpty {
            self.platform = platform
        }
    }
    
    public var sanitizedPlatform: String {
        
        if let platform = platform {
            if platform.count == 1 {
                return "0\(platform)"
            } else {
                return String(platform.prefix(2))
            }
        } else {
            return "  "
        }
        
    }
    
}
