//
//  TransportTypeUi.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Foundation

public enum TransportTypeUi: String, Codable, CaseIterable, Hashable, Equatable {
    
    case footpath = "footpath"
    
    /**
     This is the german 'Zug'.
     */
    case train = "train"
    
    /**
     This is the german 'S-Bahn'.
     */
    case suburbanRailway = "suburban_railway"
    
    /**
     This is the german 'U-Bahn'.
     */
    case subway = "subway"
    
    /**
     This is the german 'Stadtbahn'.
     */
    case metro = "metro"
    
    /**
     This is the german 'Straßenbahn'.
     */
    case tram = "tram"
    
    /**
     This is the german 'Stadtbus'.
     */
    case cityBus = "city_bus"
    
    /**
     This is the german 'Regionalbus'.
     */
    case regionalBus = "regional_bus"
    
    /**
     This is the german 'Schnellbus'.
     */
    case rapidBus = "rapid_bus"
    
    /**
     This is the german 'Seil-/Zahnradbahn'.
     */
    case cableCar = "cable_car"
    
    /**
     This is the german 'AST/Rufbus'.
     */
    case onCallBus = "on_call_bus"
    
    /**
     This is the german 'Schwebebahn'.
     */
    case suspensionRailway = "suspension_railway"
    
    /**
     This is the german 'Flugzeug'.
    */
    case plane = "plane"
    
    /**
     This is the german 'Regionalzug' (e.g. IRE, RE and RB).
     */
    case regionalTrain = "regional_train"
    
    /**
     This is the german 'Nationaler Zug' (e.g. IR and D).
     */
    case nationalTrain = "national_train"
    
    /**
     This is the german 'Internationaler Zug' (e.g. IC and EC).
     */
    case internationalTrain = "international_train"
    
    /**
     This is the german 'Hochgeschwindigkeitszug' (e.g. ICE).
     */
    case highSpeedTrain = "high_speed_train"
    
    /**
     This is the german 'Schienenersatzverkehr'.
     */
    case railReplacementService = "rail_replacement_service"
    
    /**
     This is the german 'Schuttlezug'.
     */
    case shuttleTrain = "shuttle_train"
    
    /**
     This is the german 'Bürgerbus'.
     */
    case communityBus = "community_bus"
    
    public var localizedName: String {
        switch self {
            case .footpath:
                return "Fußweg"
                
            case .train:
                return "Zug"
                
            case .suburbanRailway:
                return "S-Bahn"
                
            case .subway:
                return "U-Bahn"
                
            case .metro:
                return "Stadtbahn"
                
            case .tram:
                return "Straßenbahn"
                
            case .cityBus:
                return "Stadtbus"
                
            case .regionalBus:
                return "Regionalbus"
                
            case .rapidBus:
                return "Schnellbus"
                
            case .cableCar:
                return "Seil-/Zahnradbahn"
                
            case .onCallBus:
                return "AST/Rufbus"
                
            case .suspensionRailway:
                return "Schwebebahn"
                
            case .plane:
                return "Flugzeug"
                
            case .regionalTrain:
                return "Regionalzug"
                
            case .nationalTrain:
                return "Nationaler Zug"
                
            case .internationalTrain:
                return "Internationaler Zug"
                
            case .highSpeedTrain:
                return "Hochgeschwindigkeitszug"
                
            case .railReplacementService:
                return "Schienenersatzverkehr"
                
            case .shuttleTrain:
                return "Schuttlezug"
                
            case .communityBus:
                return "Bürgerbus"
        }
    }
    
}

public extension Optional where Wrapped == TransportType {
    
    func toUiType() -> TransportTypeUi {
        
        guard let type = self else {
            return .footpath
        }
        
        switch type {
            case .train:
                return .train
            case .suburbanRailway:
                return .suburbanRailway
            case .subway:
                return .subway
            case .metro:
                return .metro
            case .tram:
                return .tram
            case .cityBus:
                return .cityBus
            case .regionalBus:
                return .regionalBus
            case .rapidBus:
                return .rapidBus
            case .cableCar:
                return .cableCar
            case .onCallBus:
                return .onCallBus
            case .suspensionRailway:
                return .suspensionRailway
            case .plane:
                return .plane
            case .regionalTrain:
                return .regionalTrain
            case .nationalTrain:
                return .nationalTrain
            case .internationalTrain:
                return .internationalTrain
            case .highSpeedTrain:
                return .highSpeedTrain
            case .railReplacementService:
                return .railReplacementService
            case .shuttleTrain:
                return .shuttleTrain
            case .communityBus:
                return .communityBus
        }
        
    }
    
}
