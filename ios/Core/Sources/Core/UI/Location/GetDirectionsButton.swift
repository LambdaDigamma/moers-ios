//
//  GetDirectionsButton.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import SwiftUI

public struct GetDirectionsButton: View {
    
    public let action: () -> Void
    public let travelTime: TimeInterval?
    public let mode: DirectionsMode
    
    public init(
        action: @escaping () -> Void,
        travelTime: TimeInterval? = nil,
        mode: DirectionsMode = .driving
    ) {
        self.action = action
        self.travelTime = travelTime
        self.mode = mode
    }
    
    public var systemImageName: String {
        switch mode {
            case .default:
                return "car.fill"
            case .driving:
                return "car.fill"
            case .transit:
                return "tram.fill"
            case .walking:
                return "figure.walk"
        }
    }
    
    public var body: some View {
        
        Button(action: action) {
            Label(time, systemImage: systemImageName)
        }
        .buttonStyle(PrimaryButtonStyle())
        
    }
    
    public var time: String {
        
        if let travelTime = travelTime {
            return Self.durationFormatter.string(from: travelTime)
                ?? AppStrings.Directions.getDirections
        } else {
            return AppStrings.Directions.getDirections
        }
        
    }
    
    internal static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour]
        formatter.formattingContext = .standalone
        formatter.unitsStyle = .full
        return formatter
    }()
    
}

struct GetDirectionsButton_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            GetDirectionsButton(action: {})
                .padding()
                .previewLayout(.sizeThatFits)
            
            GetDirectionsButton(action: {}, travelTime: 60 * 5)
                .padding()
                .previewLayout(.sizeThatFits)
            
            GetDirectionsButton(action: {}, travelTime: 60 * 130, mode: .transit)
                .padding()
                .previewLayout(.sizeThatFits)
            
            GetDirectionsButton(action: {}, travelTime: 60 * 5, mode: .walking)
                .padding()
                .previewLayout(.sizeThatFits)
            
        }
        .preferredColorScheme(.dark)
        
    }
}
