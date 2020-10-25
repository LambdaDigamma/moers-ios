//
//  CovidMediumWidget.swift
//  Moers
//
//  Created by Lennart Fischer on 25.10.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import SwiftUICharts

struct CovidMediumWidget: View {
    var body: some View {
        ZStack {
            Color.clear
            
            GeometryReader { geometry in
                
                HStack {
                 
                    VStack(alignment: .leading, spacing: 8) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🦠 Inzidenz".uppercased())
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            
                            VStack(alignment: .leading) {
                                
                                HStack(alignment: VerticalAlignment.center) {
                                    Group {
                                        Text("95,0").font(.title)
                                            .fontWeight(.bold)
                                        Text("▲")
                                            .font(.headline)
                                    }.foregroundColor(.red)
                                    Text("(+167)")
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                }
                                Text("Wesel")
                                
                            }
                            
                        }
                        
                        VStack(alignment: .leading) {
                            HStack(alignment: VerticalAlignment.center) {
                                Group {
                                    Text("67,5")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                    
                                    Text("▲")
                                        .font(.system(size: 10, weight: .bold, design: .default))
                                }.foregroundColor(.red)
                                Text("NRW")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                            }
                            
                            Text("Stand: 24.10.2020")
                                .foregroundColor(.secondary)
                                .font(.system(size: 10, weight: Font.Weight.regular, design: Font.Design.default))
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: geometry.size.width / 2)
                    
                    Spacer()
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(maxWidth: 1)
                        .opacity(0.2)
                        .padding(.vertical)
                    Spacer()
                    
                    VStack {
                        MultiLineChartView(data: [([8,32,11,23,40,28], GradientColors.green), ([90,99,78,111,70,60,77], GradientColors.purple), ([34,56,72,38,43,100,50], GradientColors.orngPink)], title: "Title")
                    }
                    .padding()
                    .frame(maxWidth: geometry.size.width / 2)
                    
                }
                
            }
            
            
        }
            
    }
}

@available(iOS 14.0, *)
struct CovidMediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        CovidMediumWidget()
            .previewLayout(.fixed(width: 360, height: 169))
            .previewDisplayName("Medium widget")
    }
}
