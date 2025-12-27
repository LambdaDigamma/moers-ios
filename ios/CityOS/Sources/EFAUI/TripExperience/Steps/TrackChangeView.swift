//
//  TrackChangeView.swift
//  
//
//  Created by Lennart Fischer on 25.12.22.
//

import SwiftUI
import EFAAPI

public struct TripPartialRouteTrack: Equatable, Hashable {
    
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
    
}

public struct TrackChangeData: Equatable, Hashable {
    
    public let fromTrack: TripPartialRouteTrack
    public let toTrack: TripPartialRouteTrack
    
    public let currentChangeTime: Measurement<UnitDuration>
    
    public let formattedTime: String
    
    public init(
        fromTrack: TripPartialRouteTrack,
        toTrack: TripPartialRouteTrack,
        currentChangeTime: Measurement<UnitDuration>
    ) {
        self.fromTrack = fromTrack
        self.toTrack = toTrack
        self.currentChangeTime = currentChangeTime
        self.formattedTime = currentChangeTime.formatted()
    }
    
}

public struct TrackChangeView: View {
    
    public let data: TrackChangeData
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            Group {
                Text("\(Image(systemName: "shuffle")) Track change")
            }
            .font(.body.weight(.semibold))
            .foregroundColor(.yellow)
            
            HStack(spacing: 32) {
                
                trackInfo(name: data.fromTrack.name)
                
                Image(systemName: "arrow.right")
                    .font(.largeTitle.weight(.semibold))
                
                trackInfo(name: data.toTrack.name)
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .center) {
                Text("Current changeover time: \(data.formattedTime)")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        
    }
    
    @ViewBuilder
    func trackInfo(name: String) -> some View {
        
        Text(name)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .frame(minWidth: 80, idealWidth: 50)
            .background(Color(UIColor.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .font(.largeTitle.weight(.semibold))
        
    }
    
//    static let formatter =
    
}

struct TrackChangeView_Previews: PreviewProvider {
    
    static let changeData = TrackChangeData(
        fromTrack: .init(name: "3"),
        toTrack: .init(name: "6"),
        currentChangeTime: .init(value: 7, unit: .minutes)
    )
    
    static var previews: some View {
        TrackChangeView(data: changeData)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
