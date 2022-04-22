//
//  LineMeter.swift
//  
//
//  Created by Lennart Fischer on 10.01.22.
//

import SwiftUI

struct BinaryValueTestingView<Content: View>: View {
    
    @State var value: Double = 0.5
    
    var content: (Double) -> Content
    
    public init(content: @escaping (Double) -> Content) {
        self.content = content
    }
    
    var body: some View {
        
        VStack {
            
            content(value)
            
            Slider(value: $value, in: 0...1)
            
        }
        .padding()
        
    }
    
}

struct LineMeter: View {
    
    @ScaledMetric private var height: CGFloat = 32
    
    private let numberOfLines: Int = 20
    private let value: Double
    private let disabledOpacity: Double = 0.2
    private let colors: [Color]
    
    public init(value: Double, colors: [Color] = [Color.blue, .green]) {
        self.value = value
        self.colors = colors
    }
    
    private var numberOfFilled: Int {
        return Int(Double(numberOfLines) * value)
    }
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
            
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask {
                HStack(spacing: 6) {
                    
                    ForEach(0..<numberOfLines, id: \.self) { num in
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                num < numberOfFilled ? .blue
                                    : .secondary.opacity(disabledOpacity)
                            )
                        
                    }
                    
                }
            }
            .frame(height: height)
            .accessibilityValue("\(value) percent")
            
        } else {
            
            HStack(spacing: 8) {
                
                ForEach(0..<numberOfLines, id: \.self) { num in
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(num < numberOfFilled ? .blue : .secondary.opacity(0.2))
                    
                }
                
            }
            .frame(height: height)
            .accessibilityValue("\(value) percent")
            
        }
        
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        BinaryValueTestingView { value in
            
            VStack {
                
                LineMeter(value: value)
                    .padding()
                    .frame(maxWidth: 300)
                    .previewLayout(.sizeThatFits)
                
                LineMeter(value: value, colors: [Color.green, Color.yellow, Color.red])
                    .padding()
//                    .frame(maxWidth: 300)
                    .previewLayout(.sizeThatFits)
                
            }
            
        }
        
    }
    
}
