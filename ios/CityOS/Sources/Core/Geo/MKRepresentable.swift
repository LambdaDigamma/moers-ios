//
//  MKRepresentable.swift
//  
//
//  Created by Lennart Fischer on 29.01.22.
//

import Foundation
import MapKit
import CoreLocation

public enum DirectionsMode {
    case `default`
    case driving
    case transit
    case walking
    
    #if !os(tvOS)
    public func toLaunchOption() -> String {
        switch self {
            case .default:
                return MKLaunchOptionsDirectionsModeDefault
            case .driving:
                return MKLaunchOptionsDirectionsModeDriving
            case .transit:
                return MKLaunchOptionsDirectionsModeTransit
            case .walking:
                return MKLaunchOptionsDirectionsModeWalking
        }
    }
    
    #endif

    public func toDirectionsTransportType() -> MKDirectionsTransportType {
        switch self {
            case .default:
                return .any
            case .driving:
                return .automobile
            case .transit:
                return .transit
            case .walking:
                return .walking
        }
    }
}

public protocol MKRepresentable {
    
    func toMapItem() -> MKMapItem
    
    #if !os(tvOS)
    func startNavigation(mode: DirectionsMode)
    
    #endif
}

#if !os(tvOS)
public extension MKRepresentable {

    func startNavigation(mode: DirectionsMode) {
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: mode.toLaunchOption()]
        
        self.toMapItem().openInMaps(launchOptions: launchOptions)
        
    }
    
}

#endif
