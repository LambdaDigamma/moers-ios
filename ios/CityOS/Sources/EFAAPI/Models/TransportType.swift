//
//  TransportType.swift
//  EFAAPI
//
//  Created by Lennart Fischer on 11.02.20.
//

import Foundation

public enum TransportType: Int, Codable, CaseIterable, Equatable, Hashable, Identifiable, Sendable {
    
    /**
     This is the german 'Zug'.
     */
    case train = 0
    
    /**
     This is the german 'S-Bahn'.
     */
    case suburbanRailway = 1
    
    /**
    This is the german 'U-Bahn'.
    */
    case subway = 2
    
    /**
     This is the german 'Stadtbahn'.
     */
    case metro = 3
    
    /**
     This is the german 'Straßenbahn'.
    */
    case tram = 4

    /**
     This is the german 'Stadtbus'.
     */
    case cityBus = 5
    
    /**
     This is the german 'Regionalbus'.
     */
    case regionalBus = 6
    
    /**
     This is the german 'Schnellbus'.
     */
    case rapidBus = 7
    
    /**
     This is the german 'Seil-/Zahnradbahn'.
     */
    case cableCar = 8
    
    /**
     This is the german 'AST/Rufbus'.
     */
    case onCallBus = 10
    
    /**
     This is the german 'Schwebebahn'.
     */
    case suspensionRailway = 11
    
    /**
     This is the german 'Flugzeug'.
     */
    case plane = 12
    
    /**
     This is the german 'Regionalzug' (e.g. IRE, RE and RB).
    */
    case regionalTrain = 13
    
    /**
     This is the german 'Nationaler Zug' (e.g. IR and D).
    */
    case nationalTrain = 14
    
    /**
     This is the german 'Internationaler Zug' (e.g. IC and EC).
    */
    case internationalTrain = 15
    
    /**
     This is the german 'Hochgeschwindigkeitszug' (e.g. ICE).
    */
    case highSpeedTrain = 16
    
    /**
     This is the german 'Schienenersatzverkehr'.
    */
    case railReplacementService = 17
    
    /**
     This is the german 'Schuttlezug'.
    */
    case shuttleTrain = 18
    
    /**
     This is the german 'Bürgerbus'.
    */
    case communityBus = 19
    
    public var localizedName: String {
        switch self {
            case .train:
                return String(localized: "Train", bundle: .module)
            
            case .suburbanRailway:
                return String(localized: "Suburban Railway", bundle: .module)
                
            case .subway:
                return String(localized: "Subway", bundle: .module)
                
            case .metro:
                return String(localized: "Metro", bundle: .module)
                
            case .tram:
                return String(localized: "Tram", bundle: .module)
                
            case .cityBus:
                return String(localized: "City Bus", bundle: .module)
                
            case .regionalBus:
                return String(localized: "Regional Bus", bundle: .module)
                
            case .rapidBus:
                return String(localized: "Rapid Bus", bundle: .module)
                
            case .cableCar:
                return String(localized: "Cable Car", bundle: .module)
                
            case .onCallBus:
                return String(localized: "On-call Bus", bundle: .module)
                
            case .suspensionRailway:
                return String(localized: "Suspension Railway", bundle: .module)
            
            case .plane:
                return String(localized: "Plane", bundle: .module)
                
            case .regionalTrain:
                return String(localized: "Regional Train", bundle: .module)
                
            case .nationalTrain:
                return String(localized: "National Train", bundle: .module)
                
            case .internationalTrain:
                return String(localized: "International Train", bundle: .module)
                
            case .highSpeedTrain:
                return String(localized: "High-speed Train", bundle: .module)
                
            case .railReplacementService:
                return String(localized: "Rail Replacement Service", bundle: .module)
                
            case .shuttleTrain:
                return String(localized: "Shuttle Train", bundle: .module)
                
            case .communityBus:
                return String(localized: "Community Bus", bundle: .module)
        }
    }
    
    public var id: Int {
        return self.rawValue
    }
    
}
