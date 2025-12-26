//
//  HeadingView.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import SwiftUI
import Core
import CoreLocation

internal extension Double {
    
    var radians: Double {
        Measurement(value: self, unit: UnitAngle.degrees)
            .converted(to: .radians)
            .value
    }
    
    var degrees: Double {
        Measurement(value: self, unit: UnitAngle.radians)
            .converted(to: .degrees)
            .value
    }
    
}

public struct HeadingIndicator<Content: View>: View {
    
    let currentLocation: CLLocationCoordinate2D
    let currentHeading: CLHeading
    let targetLocation: CLLocationCoordinate2D
    let content: Content
    
    private var targetBearing: Double {
        let deltaL = targetLocation.longitude.radians - currentLocation.longitude.radians
        let thetaB = targetLocation.latitude.radians
        let thetaA = currentLocation.latitude.radians
        
        let x = cos(thetaB) * sin(deltaL)
        let y = cos(thetaA) * sin(thetaB) - sin(thetaA) * cos(thetaB) * cos(deltaL)
        let bearing = atan2(x, y)
        
        return bearing.degrees
    }
    
    private var targetHeading: Double {
        targetBearing - currentHeading.magneticHeading
    }
    
    public init(
        currentLocation: CLLocationCoordinate2D,
        currentHeading: CLHeading,
        targetLocation: CLLocationCoordinate2D,
        content: Content
    ) {
        self.currentLocation = currentLocation
        self.currentHeading = currentHeading
        self.targetLocation = targetLocation
        self.content = content
    }
    
    public init(
        currentLocation: CLLocationCoordinate2D,
        currentHeading: CLHeading,
        targetLocation: CLLocationCoordinate2D,
        @ViewBuilder contentBuilder: () -> Content
    ) {
        self.currentLocation = currentLocation
        self.currentHeading = currentHeading
        self.targetLocation = targetLocation
        self.content = contentBuilder()
    }
    
    public var body: some View {
        content
            .rotationEffect(.degrees(self.targetHeading))
    }
    
}

public struct HeadingView: View {
    
    @StateObject private var locationManager = CoreLocationObject()
    
    public var body: some View {
        VStack {
            
            if let heading = locationManager.heading, let location = locationManager.location {
                
                HeadingIndicator(
                    currentLocation: location.coordinate,
                    currentHeading: heading,
                    targetLocation: CLLocationCoordinate2D(latitude: 51.44961, longitude: 6.61736)
                ) {
                    Image(systemName: "arrow.up.circle")
                }
                
            }
            
        }
        .padding()
        .background(Color.systemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task {
            locationManager.beginUpdatingHeading(.authorizedWhenInUse)
        }
        .onDisappear {
            locationManager.endUpdatingHeading()
        }
    }
    
}

struct HeadingView_Previews: PreviewProvider {
    static var previews: some View {
        HeadingView()
    }
}
