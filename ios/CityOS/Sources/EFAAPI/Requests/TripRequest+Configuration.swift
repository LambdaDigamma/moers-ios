//
//  TripRequestConfiguration.swift
//  
//
//  Created by Lennart Fischer on 08.04.22.
//

import Foundation

public enum RouteType: String, Codable, CaseIterable, Identifiable {
    
    case leastTime = "LEASTTIME"
    case leastInterchange = "LEASTINTERCHANGE"
    case leastWalking = "LEASTWALKING"
    
    public var id: String {
        self.rawValue
    }
    
    public var localizedName: String {
        switch self {
            case .leastTime:
                return "schnellste Verbindung"
            case .leastInterchange:
                return "wenigste Umstiege"
            case .leastWalking:
                return "kürzeste Fußwege"
        }
    }
    
}

public enum ChangeSpeed: String, Codable, CaseIterable, Identifiable {
    
    case fast = "fast"
    case normal = "normal"
    case slow = "slow"
    
    public var id: String {
        self.rawValue
    }
    
    public var localizedName: String {
        switch self {
            case .fast:
                return "Schnell"
            case .normal:
                return "Normal"
            case .slow:
                return "Langsam"
        }
    }
    
}

public enum LineRestriction: Int, Codable {
    
    /// All lines (`alle Linien`)
    case `default` = 400
    
    /// All lines with out ICE (`alle Linien außer ICE`)
    case withoutICE = 401
    
    /// All lines in network without surcharge (`Verbund ohne Aufschlag`)
    case networkWithoutSurcharge = 402
    
    /// All lines in network and local transport (`Verbund und Nahverkehr`)
    case networkAndLocalTransport = 403
    
}

extension TripRequest {
    
    public struct Configuration: Equatable, Hashable, Codable {
        
        internal init(
            calcNumberOfTrips: Int = 4,
            calcOneDirection: Bool = true,
            useRealtime: Bool = true,
            imparedOptionsActive: Bool = false,
            lowPlatformVhcl: Bool = false,
            noElevators: Bool = false,
            noSolidStairs: Bool = false,
            wheelchair: Bool = false,
            maxChanges: Int = 9,
            routeType: RouteType = .leastTime
        ) {
            self.calcNumberOfTrips = calcNumberOfTrips
            self.calcOneDirection = calcOneDirection
            self.useRealtime = useRealtime
            self.imparedOptionsActive = imparedOptionsActive
            self.lowPlatformVhcl = lowPlatformVhcl
            self.noElevators = noElevators
            self.noSolidStairs = noSolidStairs
            self.wheelchair = wheelchair
            self.maxChanges = maxChanges
            self.routeType = routeType
        }
        
        public init() {
            
        }
        
        /// Specifies the number of trips by public transport.
        /// By default, four trips are calculated.
        /// If there are alternative trips, the specified number can be exceeded.
        public var calcNumberOfTrips: Int = 4
        
        /// By default, one of the trips is output before the selected
        /// departure time or after the selected arrival time.
        /// This parameter suppresses the default behavior.
        public var calcOneDirection: Bool = true
        
        /// Activates the real-time monitoring feature
        public var useRealtime: Bool = true
        
        /// Activates the parameters for limited mobility.
        public var imparedOptionsActive: Bool = false
        
        /// If this parameter is activated, only low-floor
        /// vehicles are taken into account.
        public var lowPlatformVhcl: Bool = false
        
        /// Only journeys with transfers that do not take place
        /// via escalators will be reported.
        public var noElevators: Bool = false
        
        /// Only journeys with transfers that do not take place
        /// via normal stairs will be reported.
        public var noSolidStairs: Bool = false
        
        /// Only wheelchair-accessible vehicles are taken into account
        /// in the information. Wheelchair-accessible vehicles have a
        /// lift or ramp or allow level access.
        public var wheelchair: Bool = false
        
        /// Maximum number of changes in a trip.
        /// Trips with more than the specified number of transfers will
        /// be discarded during the trip calculation.
        /// By default, 9 transfers are defined as the maximum number.
        /// Possible values are:
        /// 0 (direct connection), 1, 2, 9
        public var maxChanges: Int = 9
        
        /// Specifies the criteria for optimizing the trip information.
        public var routeType: RouteType = .leastTime
        
    }
    
}
