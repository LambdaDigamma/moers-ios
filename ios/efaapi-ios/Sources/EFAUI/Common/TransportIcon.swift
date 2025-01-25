//
//  TransportIcon.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import Foundation
import SwiftUI
import EFAAPI

public enum TransportIcon {
    
    public static func icon(for type: TransportType) -> Image {

        switch type {
            case .rapidBus, .cityBus, .regionalBus, .communityBus, .onCallBus:
                return Image(systemName: "bus.fill")
            case .train, .internationalTrain, .shuttleTrain, .regionalTrain, .nationalTrain, .highSpeedTrain:
                return Image(systemName: "tram.fill")
            case .metro, .suburbanRailway, .tram:
                return Image(systemName: "tram.fill")
            case .subway:
                return Image(systemName: "tram.tunnel.fill")
            case .plane:
                return Image(systemName: "airplane")
            default:
                return Image(systemName: "square.grid.3x3.fill")
        }
        
    }
    
    public static func pedestrian() -> Image {
        return Image(systemName: "figure.walk")
    }
    
    public static func icon(for type: TransportTypeUi) -> Image {
        
        switch type {
            case .rapidBus, .cityBus, .regionalBus, .communityBus, .onCallBus:
                return Image(systemName: "bus.fill")
            case .train, .internationalTrain, .shuttleTrain, .regionalTrain, .nationalTrain, .highSpeedTrain:
                return Image(systemName: "tram.fill")
            case .metro, .suburbanRailway, .tram:
                return Image(systemName: "tram.fill")
            case .subway:
                return Image(systemName: "tram.tunnel.fill")
            case .plane:
                return Image(systemName: "airplane")
            case .footpath:
                return Image(systemName: "figure.walk")
            default:
                return Image(systemName: "square.grid.3x3.fill")
        }
        
    }
    
}

public enum TransportIcon_Previews: PreviewProvider {
    
    public static var previews: some View {
        
        let allCases = TransportType.allCases
        
        VStack(alignment: .leading) {
            
            ForEach(allCases, id: \.self) { type in
                
                HStack(spacing: 20) {
                    
                    TransportIcon.icon(for: type)
                    
                    Text(type.localizedName)
                    
                }.padding()
                    
            }
            
        }.previewLayout(.sizeThatFits)
        
        
        
    }
    
}
