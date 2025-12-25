//
//  ScanQRCodeButtonStyle.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import Core

struct ScanQRCodeButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(alignment: .top, spacing: Margin.extraWide) {
            
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .frame(width: 40, height: 40, alignment: .topLeading)
                .foregroundColor(.label)
            
            VStack(alignment: .leading, spacing: Margin.standard) {
                configuration.label
                    .font(.title)
                    .foregroundColor(.label)
                Text("An jedem Ausstellungsort findest Du einen QR Code. Scanne ihn, um weitere spannende Informationen zum Exponant zu erhalten.")
                    .font(.headline)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(Margin.extraWide)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

