//
//  ParkingLotWidget.swift
//  Moers
//
//  Created by Lennart Fischer on 06.03.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI

struct ParkingLotWidget: View {
    
    let green = UIColor(red: 0.024, green: 0.647, blue: 0.176, alpha: 1.000)
    
    var body: some View {
        ZStack {
            Color.systemBackground
            
            HStack() {
                
                ZStack {
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(Color.blue)
                    //                            .stroke(Color.white)
                                .aspectRatio(1, contentMode: .fit)
                            Text("P")
                                .font(.largeTitle).fontWeight(.heavy)
                                .foregroundColor(.white)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        
                        
                        Text("vor 3min")
                            .foregroundColor(.secondary)
                    }.padding()
                    
                }
                .frame(maxWidth: 120,
                       maxHeight: .infinity,
                       alignment: .center)
                
                VStack {
                    
                    HStack {
                        Text("Parkhaus Braun")
                        Spacer()
                        Text("156")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(green)))
                            .foregroundColor(.white)
                    }
                    .font(.headline)
                    
                    
                }.padding()
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .topLeading)
                
            }.frame(maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading)
            
//            VStack(alignment: .leading) {
//                Text("Test")
//            }
//            .padding()
//            .frame(maxWidth: .infinity,
//                   maxHeight: .infinity,
//                   alignment: .topLeading)
        }
    }
}

struct ParkingLotWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        let widget = ParkingLotWidget()
            .previewLayout(.fixed(width: 360, height: 169))
        
        return Group {
            widget
            widget.environment(\.colorScheme, .dark)
        }
    }
}
