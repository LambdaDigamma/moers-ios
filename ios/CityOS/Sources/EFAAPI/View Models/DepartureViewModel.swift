//
//  DepartureViewModel.swift
//  
//
//  Created by Lennart Fischer on 08.12.21.
//

import SwiftUI

public class DepartureViewModel: Identifiable, ObservableObject {
    
    public let id: UUID = UUID()
    private let model: ITDDeparture
    
    @Published public var description: String
    @Published public var time: Date?
    @Published public var actual: Date?
    @Published public var transportType: TransportType
    @Published public var platform: String?
    @Published public var direction: String = ""
    @Published public var symbol: String
    
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
