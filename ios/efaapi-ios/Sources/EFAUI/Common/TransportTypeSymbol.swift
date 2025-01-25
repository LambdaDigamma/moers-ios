//
//  TransportTypeSymbol.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import SwiftUI
import EFAAPI

public struct TransportTypeSymbol: View {
    
    @ScaledMetric public var size: Double = 20
    
    public let transportType: TransportType
    
    public init(
        transportType: TransportType,
        size: Double = 20
    ) {
        self._size = .init(wrappedValue: size)
        self.transportType = transportType
    }
    
    public var body: some View {
        
        let displayData = data(type: transportType)
        let transportImage = TransportIcon.icon(for: transportType)
        
        transportImage
            .resizable()
            .scaledToFit()
            .frame(width: size, height: 20)
            .padding(8)
            .foregroundColor(displayData.foreground)
            .background(Circle()
                            .fill(displayData.background))
            .accessibility(label: Text(transportType.localizedName))
        
    }
    
    private func data(type: TransportType) -> (background: Color, foreground: Color) {
        
        switch type {
            case .rapidBus, .cityBus, .regionalBus, .communityBus, .onCallBus:
                return (Color.green, Color.white)
            case .train, .internationalTrain, .shuttleTrain, .regionalTrain, .nationalTrain, .highSpeedTrain:
                return (Color.red, Color.white)
            case .metro, .suburbanRailway, .tram:
                return (Color.green, Color.white)
            case .subway:
                return (Color.blue, Color.white)
            case .plane:
                return (Color.black, Color.white)
            default:
                return (Color.black, Color.white)
        }
        
    }
    
}

struct TransportTypeSymbol_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let cases = TransportType.allCases
        
        VStack(alignment: .leading) {
            
            ForEach(cases, id: \.self) { t in
                
                HStack(spacing: 16) {
                    TransportTypeSymbol(transportType: t)
                    Text("Duisburg")
                }
                .padding()
                
            }
            
        }.previewLayout(.sizeThatFits)
        
    }
    
}
