//
//  ScanStationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import CarBode
import Core

struct ScanStationView: View {
    
    var scannedQRCode: (_ scannedValue: String) -> Void
    
    var body: some View {
        
        ZStack {
            
            Color.systemBackground
            
            VStack(spacing: Margin.extraWide) {
                
                CBScanner(
                    supportBarcode: .constant([.qr]),
                    scanInterval: .constant(5.0),
                    mockBarCode: .constant(BarcodeData(value: "https://archiv.moers-festival.de/moers21/sonderprojekte/ausstellung/ort/1", type: .qr))
                ) {
                    
                    scannedQRCode($0.value)
                    
                    print("BarCodeType = ", $0.type.rawValue, "Value = ", $0.value)
                    
                } onDraw: {
                    
                    let lineWidth: CGFloat = 2
                    let lineColor = UIColor.red
                    
                    // Fill color with opacity
                    // You also can use UIColor.clear if you don't want to draw fill color
                    let fillColor = UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.4)
                    
                    $0.draw(lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
                    
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(Margin.wide)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary, lineWidth: 2)
                )
                
                Text(LocalizedStringKey("ScanStationPrompt"))
                    .multilineTextAlignment(.leading)
                
                
            }.padding()
            
        }
        
    }
    
}

struct ScanStationView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            ScanStationView(scannedQRCode: { url in
                
            })
        }
        .navigationBarHidden(true)
        .environment(\.colorScheme, .dark)
        
    }
}
