//
//  CovidMediumWidget.swift
//  Moers
//
//  Created by Lennart Fischer on 25.10.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import Charts

struct CovidMediumWidget: View {
    
    var data = [
        1, 1, 1, 0.84, 0.9
    ]
    
    var body: some View {
        ZStack {
            Color.systemBackground
            
            GeometryReader { geometry in
                
                HStack(alignment: .top) {
                 
                    VStack(alignment: .leading, spacing: 8) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🦠 Inzidenz".uppercased())
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            
                            VStack(alignment: .leading) {
                                
                                HStack(alignment: VerticalAlignment.center) {
                                    Group {
                                        Text("56,3").font(.title)
                                            .fontWeight(.bold)
                                        Text("▲")
                                            .font(.headline)
                                    }.foregroundColor(.red)
                                    Text("(+167)")
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                }
                                Text("Kreis Wesel")
                                
                            }
                            
                        }
                        
                        VStack(alignment: .leading) {
                            HStack(alignment: VerticalAlignment.center) {
                                Group {
                                    Text("95,9")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                    
                                    Text("▲")
                                        .font(.system(size: 10, weight: .bold, design: .default))
                                }.foregroundColor(.red)
                                Text("NRW")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                            }
                            
                            Text("Stand: 25.10.2020")
                                .foregroundColor(.secondary)
                                .font(.system(size: 10, weight: Font.Weight.regular, design: Font.Design.default))
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: geometry.size.width / 2, maxHeight: geometry.size.height)
                    
                    Spacer()
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(maxWidth: 1)
                        .opacity(0.2)
                        .padding(.vertical)
                    Spacer()
                    
                    VStack {
                        VStack {
//                            Text("Verlauf")
                            Chart(data: data)
                                .chartStyle(
                                    LineChartStyle(.quadCurve, lineColor: .red, lineWidth: 3)
                                )
                            
                            HStack {
                                Text("64,3")
                                    .font(.system(size: 8, weight: .regular, design: .rounded))
                                Spacer()
                                Text("56,3")
                                    .font(.system(size: 8, weight: .regular, design: .rounded))
                            }
                        }.padding()
                        
                        
                    }
                    
                    .padding()
                    .frame(maxWidth: geometry.size.width / 2, maxHeight: geometry.size.height)
                    
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
//            .makeForPreviewProvider(includeLightMode: true,
//                                    includeDarkMode: true,
//                                    includeRightToLeftMode: false,
//                                    includeLargeTextMode: false)
    }
}
