//
//  TripLine.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import SwiftUI
import EFAAPI

struct TripStep {
    
    var date: Date
    
}

struct TripLine: View {
    
    private let circleSize: Double = 32
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 4)
                .fill()
                .frame(maxWidth: .infinity, maxHeight: 4)
            
            HStack {
                
                step(type: .cityBus)
                
                Spacer()
                
                step(type: .plane)
                
                Spacer()
                
                step(type: .metro)
                
                Spacer()
                
                step(type: .tram)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
    @ViewBuilder
    private func step(type: TransportType) -> some View {
        
        Circle()
            .fill(Color.primary)
            .frame(width: circleSize, height: circleSize)
            .overlay(ZStack {
                TransportIcon.icon(for: type)
                    .foregroundColor(.white)
            })
        
    }
    
}

struct TripLine_Previews: PreviewProvider {
    static var previews: some View {
        TripLine()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
