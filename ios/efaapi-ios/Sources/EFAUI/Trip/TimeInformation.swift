//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import SwiftUI

public struct TimeInformation: View {
    
    public let accentColor: Color
    public let onAccent: Color
    
    public let plannedDeparture: Date
    public let realtimeDeparture: Date
    
    public let plannedArrival: Date
    public let realtimeArrival: Date
    
    public let isBoardedTrain: Bool
    
    public init(
        accentColor: Color = Color.accentColor,
        onAccent: Color = Color.black,
        plannedDeparture: Date,
        realtimeDeparture: Date,
        plannedArrival: Date,
        realtimeArrival: Date,
        isBoardedTrain: Bool = false
    ) {
        self.accentColor = accentColor
        self.onAccent = onAccent
        self.plannedDeparture = plannedDeparture
        self.realtimeDeparture = realtimeDeparture
        self.plannedArrival = plannedArrival
        self.realtimeArrival = realtimeArrival
        self.isBoardedTrain = isBoardedTrain
    }
    
    public var body: some View {
        
        VStack {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(maxWidth: .infinity, maxHeight: 4)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(accentColor)
                    .frame(maxWidth: 100, maxHeight: 4, alignment: .leading)
                
                HStack {
                    
                    Circle()
                        .fill(isBoardedTrain ? accentColor : Color(UIColor.secondarySystemBackground))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 16)
                        .overlay(Circle().fill(accentColor).frame(width: 8, height: 8))
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 16)
                        .overlay(Circle().fill(accentColor).frame(width: 8, height: 8))
                    
                }
                .frame(maxWidth: .infinity)
                
            }
            
            HStack {
                
                Text("\(plannedDeparture, style: .time)") +
                Text(" (+4)")
                    .foregroundColor(.red)
                
                Spacer()
                
                Text("\(plannedArrival, style: .time)")
                
            }
            .padding(.horizontal, 8)
            .font(.title3.weight(.bold))
            
            if !isBoardedTrain {
                
                HStack {
                    
                    Text("\(Image(systemName: "timer")) \(PackageStrings.ActiveTrip.departingIn) \(realtimeDeparture, style: .relative)")
                        .foregroundColor(onAccent)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(accentColor)
                        .cornerRadius(16)
                    
                    Spacer()
                    
                    Text(PackageStrings.ActiveTrip.arrival)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color(UIColor.secondarySystemFill))
                        .cornerRadius(16)
                    
                }
                .font(.caption.weight(.bold))
                
            } else {
                
            }
            
        }
        
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        
        let plannedDeparture: Date = Date(timeIntervalSinceNow: 60 * 5)
        let realtimeDeparture: Date = Date(timeIntervalSinceNow: 60 * 9)
        
        let plannedArrival: Date = Date(timeIntervalSinceNow: 60 * 60)
        let realtimeArrival: Date = Date(timeIntervalSinceNow: 60 * 63)
        
        return Group {
            
            TimeInformation(
                plannedDeparture: plannedDeparture,
                realtimeDeparture: realtimeDeparture,
                plannedArrival: plannedArrival,
                realtimeArrival: realtimeArrival
            )
                .padding()
                .previewLayout(.sizeThatFits)
        
            TimeInformation(
                accentColor: .orange, onAccent: .black,
                plannedDeparture: plannedDeparture,
                realtimeDeparture: realtimeDeparture,
                plannedArrival: plannedArrival,
                realtimeArrival: realtimeArrival
            )
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            
        }
        
    }
}
