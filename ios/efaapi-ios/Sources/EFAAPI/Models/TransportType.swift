//
//  TransportType.swift
//  EFAAPI
//
//  Created by Lennart Fischer on 11.02.20.
//

import Foundation

public enum TransportType: Int, Codable, CaseIterable, Equatable, Hashable, Identifiable {
    
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
    
    public var id: Int {
        return self.rawValue
    }
    
}
