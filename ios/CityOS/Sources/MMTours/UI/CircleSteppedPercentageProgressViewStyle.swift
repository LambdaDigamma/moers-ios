//
//  CircleSteppedPercentageProgressViewStyle.swift
//  
//
//  Created by Lennart Fischer on 18.12.20.
//

import SwiftUI
import MMCommon

public struct CircleSteppedPercentageProgressViewStyle : ProgressViewStyle {
    
    private var total: Int
    
    init(total: Int) {
        self.total = total
    }
    
    public func makeBody(configuration: LinearProgressViewStyle.Configuration) -> some View {
        
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(Color.secondary.opacity(0.5))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.accentColor)
                .rotationEffect(.degrees(-90))
            
            VStack(alignment: .center, spacing: 0) {
                
                Text("\(Int((configuration.fractionCompleted ?? 0) * 100)) %")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                
                Text("\(Double(total) * (configuration.fractionCompleted ?? 0), specifier: "%.0f")/\(total)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.secondary)
                
            }
            
        }
        
    }
    
}

struct DemoPageView: View {
    
    @State private var downloadAmount = 10.0
    
    var body: some View {
        NavigationView {
            VStack {
                ProgressView("Downloading…", value: downloadAmount, total: 50)
                    .progressViewStyle(CircleSteppedPercentageProgressViewStyle(total: 50))
                    .frame(width: 74, height: 74, alignment: .center)
                    .padding()
                
                Button(action: {
                    withAnimation {
                        if downloadAmount < 50 {
                            downloadAmount += 1
                        }
                    }
                }, label: {
                    Text("+1")
                })
            }
            .navigationBarTitle("ProgressView", displayMode: .inline)
        }
        
    }
    
}

struct DemoPageView_Previews: PreviewProvider {
    static var previews: some View {
        DemoPageView()
    }
}
