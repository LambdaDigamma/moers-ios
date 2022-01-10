//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 10.01.22.
//

import SwiftUI

public struct ProgressMeterView: View {
    
    @ScaledMetric private var height: CGFloat = 16
    
    private let value: Double
    private let backgroundColor: Color
    
    public init(value: Double, color: Color = .green) {
        self.value = value
        self.backgroundColor = color
    }
    
    public var body: some View {
        
        GeometryReader { geo in
            
            ZStack(alignment: .leading) {
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                
                Rectangle()
                    .fill(backgroundColor)
                    .frame(maxWidth: geo.size.width * value)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(8)
            
        }
        .frame(height: height, alignment: .leading)
        
    }
    
}

struct MeterView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProgressMeterView(value: 0.65)
            .padding()
            .previewLayout(.sizeThatFits)
        
        ProgressMeterView(value: 0.65)
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
    }
}
