//
//  PartialRouteView.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import SwiftUI
import EFAAPI

public struct PartialRouteView: View {
    
    public let from: PartialRouteUiState.Point
    public let to: PartialRouteUiState.Point
    public let line: String
    public let lineDestination: String
    public let transportType: TransportTypeUi
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            station(point: from)
            
            lineDetail()
            
            station(point: to)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        
    }
    
    @ViewBuilder
    private func lineDetail() -> some View {
        
        HStack(alignment: .center) {
            
            Text("\(TransportIcon.icon(for: transportType))  \(line)")
            
            Text("\(Image(systemName: "arrow.right")) \(lineDestination)")
                .foregroundColor(.primary)
                .padding(.leading, 8)
            
        }
        .font(.footnote.weight(.regular))
        .padding(.leading, 40)
        .padding()
        .background(ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(UIColor.secondarySystemFill))
                .frame(width: 4)
                .padding(.leading, 20)
        }.frame(maxWidth: .infinity, alignment: .leading))
        
    }
    
    @ViewBuilder
    private func station(point: PartialRouteUiState.Point) -> some View {
        
        HStack(alignment: .top) {
            
            VStack(alignment: .trailing) {
                
                if let realtime = point.realtimeDate, realtime != point.targetDate {
                    
                    Text(point.targetDate, style: .time)
                        .foregroundColor(.primary)
                    
                    
                    Text(realtime, style: .time)
                        .font(.footnote)
                        .foregroundColor(.green)
                    
                } else {
                    Text(point.targetDate, style: .time)
                        .foregroundColor(.primary)
                }
                
            }
            .font(.body.weight(.semibold))
            
            Text(point.stationName)
                .fontWeight(.semibold)
            
            Spacer()
            
            if !point.platform.isEmpty {
                Text("Gl. \(point.platform)")
                    .fontWeight(.medium)
            }
            
        }
        
    }
    
}

struct PartialRouteView_Previews: PreviewProvider {
    static var previews: some View {
        
        let from = PartialRouteUiState.Point(
            stationName: "Duisburg Hbf",
            targetDate: Date(timeIntervalSinceNow: 60 * 5),
            realtimeDate: Date(timeIntervalSinceNow: 60 * 7),
            platform: "2"
        )
        
        let to = PartialRouteUiState.Point(
            stationName: "Aachen Hbf",
            targetDate: Date(timeIntervalSinceNow: 60 * 80),
            realtimeDate: Date(timeIntervalSinceNow: 60 * 82),
            platform: "4"
        )
        
        return Group {
            
            PartialRouteView(
                from: from,
                to: to,
                line: "RE 1",
                lineDestination: "Aachen Hbf",
                transportType: .regionalTrain
            )
            .previewLayout(.sizeThatFits)
            
            PartialRouteView(
                from: from,
                to: to,
                line: "RE 1",
                lineDestination: "Aachen Hbf",
                transportType: .regionalTrain
            )
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            
        }
        
    }
}
