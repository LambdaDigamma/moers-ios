//
//  MapTypeViewModifier.swift
//  
//
//  Created by Lennart Fischer on 31.01.22.
//

import SwiftUI
import MapKit

public struct ShowsUserLocationKey: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var showsUserLocation: Bool {
        get { self[ShowsUserLocationKey.self] }
        set { self[ShowsUserLocationKey.self] = newValue }
    }
}

public struct ShowsUserLocation: ViewModifier {
    
    private let showsUserLocation: Bool
    
    public init(showsUserLocation: Bool) {
        self.showsUserLocation = showsUserLocation
    }
    
    public func body(content: Content) -> some View {
        content
            .environment(\.showsUserLocation, showsUserLocation)
    }
}

public struct MapTypeKey: EnvironmentKey {
    public static var defaultValue: MKMapType = .mutedStandard
}

public extension EnvironmentValues {
    var mapType: MKMapType {
        get { self[MapTypeKey.self] }
        set { self[MapTypeKey.self] = newValue }
    }
}

public struct MapType: ViewModifier {
    
    private let mapType: MKMapType
    
    public init(mapType: MKMapType) {
        self.mapType = mapType
    }
    
    public func body(content: Content) -> some View {
        content
            .environment(\.mapType, mapType)
    }
}

public extension View {
    
    func mapType(_ mapType: MKMapType) -> some View {
        return environment(\.mapType, mapType)
    }
    
    func showsUserLocation(_ showsUserLocation: Bool) -> some View {
        return environment(\.showsUserLocation, showsUserLocation)
    }
    
}
