//
//  ScalingCirclesLoader.swift
//  
//
//  Created by Lennart Fischer on 12.01.21.
//

import SwiftUI

public struct ScalingCirclesLoader: View {
    
    public init() {
        
    }
    
    @State private var shouldAnimate = false
    
    private let circleSize: CGFloat = 10
    
    public var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Circle()
                    .fill(Color.secondary)
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                    )
                Circle()
                    .fill(Color.secondary)
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.3)
                    )
                Circle()
                    .fill(Color.secondary)
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.6)
                    )
            }
            Text("Lädt...")
                .foregroundColor(Color.secondary)
                .font(.body)
        }
        .padding()
        .onAppear {
            self.shouldAnimate = true
        }
    }
    
}

struct ScalingCirclesLoader_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ScalingCirclesLoader()
        
        ScalingCirclesLoader()
            .preferredColorScheme(.dark)
        
    }
    
}

