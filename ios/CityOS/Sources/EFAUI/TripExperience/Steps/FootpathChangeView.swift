//
//  FootpathChangeView.swift
//  
//
//  Created by Lennart Fischer on 25.12.22.
//

import SwiftUI
import EFAAPI

public struct FootpathChangeData: Equatable, Hashable {
    
//    public let fromTrack: TripPartialRouteTrack
//    public let toTrack: TripPartialRouteTrack
    
    public let currentChangeTime: Measurement<UnitDuration>
    public let formattedTime: String
    
    public init(
        currentChangeTime: Measurement<UnitDuration>
    ) {
        self.currentChangeTime = currentChangeTime
        self.formattedTime = currentChangeTime.formatted()
    }
    
}

public struct FootpathChangeView: View {
    
    public let data: FootpathChangeData
    
    public init(
        data: FootpathChangeData
    ) {
        self.data = data
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Group {
                Text("\(Image(systemName: "figure.walk"))  Footpath", bundle: .module)
            }
            .font(.body.weight(.semibold))
            .foregroundColor(.yellow)
            
            HStack(spacing: 12) {
                
                Rectangle()
                    .fill(Color.secondary)
                    .frame(maxWidth: 2, maxHeight: 40)
                    .padding(.horizontal, 8)
                
                Text("413 m Fußweg (ca. 6 min)")
                
            }
            
            Group {
                Text("\(Image(systemName: "mappin.and.ellipse"))  ")
                + Text("Aachen Hbf")
            }
            .font(.body.weight(.semibold))
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
    
}

struct FootpathChangeView_Previews: PreviewProvider {
    
    static let changeData = FootpathChangeData(
        currentChangeTime: .init(value: 7, unit: .minutes)
    )
    
    static var previews: some View {
        FootpathChangeView(data: changeData)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
