//
//  DepartureMonitorForeground.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import SwiftUI
import EFAAPI

#if canImport(UIKit)

public struct DepartureMonitorForeground: View {
    
    public let stationName: String
    public let departures: [DepartureViewModel]
    public let lastUpdatedAt: Date
    public let departuresLimit: Int
    
    public init(
        stationName: String,
        departures: [DepartureViewModel],
        lastUpdatedAt: Date,
        departuresLimit: Int = 3
    ) {
        self.stationName = stationName
        self.departures = departures
        self.lastUpdatedAt = lastUpdatedAt
        self.departuresLimit = departuresLimit
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(stationName)
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 4) {
                
                let departures = departures.prefix(departuresLimit)
                
                ForEach(departures) { departure in
                    DepartureRowView(departure: departure)
                }
                
            }
            
            Spacer()
                .frame(maxHeight: 20)
            
            HStack {
                
//                    Text("nur ICE 22 & RE 5")
//                        .layoutPriority(100)
//                    Spacer()
//                        .frame(maxWidth: .infinity)
//                        .layoutPriority(50)
                
                HStack {
                    Text("Last updated: ") +
                    Text(lastUpdatedAt, style: .relative)
                }
//                .layoutPriority(100)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(.secondary)
            .font(.system(size: 8, weight: .regular, design: .default))
            
        }
        
    }
    
}

struct DepartureMonitorForeground_Previews: PreviewProvider {
    static var previews: some View {
        DepartureMonitorForeground(
            stationName: "Moers Hbf",
            departures: [
                .init(departure: .stub())
            ],
            lastUpdatedAt: Date(timeIntervalSinceNow: -5 * 60)
        )
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

#endif
