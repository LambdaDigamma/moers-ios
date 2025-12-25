//
//  TripConfiguration.swift
//  
//
//  Created by Lennart Fischer on 26.07.20.
//

import Foundation

public struct TripConfiguration {
    
    
    /**
     The value of the parameter determines whether the date and time refer to departure (dep) or arrival (arr). Default is departure.
     */
    public var tripRequestDate: TripRequestDate
    
    /**
     Activates the integration of real-time monitoring.
     */
    public var useRealtime: Bool
    
    
    public enum TripRequestDate {
        
        case arrival(date: Date)
        case departure(date: Date)
        
    }
    
    
    public func encodeParameters() -> [String: String] {
        
        var parameterContainer: [String: String] = [:]
        
        switch tripRequestDate {
            case .arrival(_):
                parameterContainer.updateValue("arr", forKey: EncodingKeys.tripDateTimeDepartureArrival.rawValue)
            default:
                parameterContainer.updateValue("dep", forKey: EncodingKeys.tripDateTimeDepartureArrival.rawValue)
        }
        
        parameterContainer.updateValue(useRealtime ? "1" : "0", forKey: EncodingKeys.useRealtime.rawValue)
        
        return parameterContainer
        
    }
    
    private enum EncodingKeys: String {
        case tripDateTimeDepartureArrival = "itdTripDateTimeDepArr"
        case useRealtime = "useRealtime"
    }
    
}
