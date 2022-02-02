//
//  ExploreOverview.swift
//  Moers
//
//  Created by Lennart Fischer on 01.02.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import SwiftUI

struct ExploreOverview: View {
    
    var columns: [GridItem] {
        return [
            .init(.flexible(minimum: 100, maximum: 400), spacing: 16, alignment: .topLeading),
            .init(.flexible(minimum: 100, maximum: 400), spacing: 16, alignment: .topLeading)
        ]
    }
    
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                
                LazyVGrid(columns: columns, spacing: 16) {
                    
                    NavigationLink {
                        
                    } label: {
                        card(
                            title: "Bürgerfunk",
                            colors: [Color.red, Color.orange],
                            systemImage: "radio.fill"
                        )
                            .foregroundColor(.label)
                    }
                    
                    card(
                        title: "Veranstaltungen",
                        colors: [Color.blue, Color.green],
                        systemImage: "calendar"
                    )
                    
                    card(
                        title: "ÖPNV",
                        colors: [Color.purple, Color.red],
                        systemImage: "bus"
                    )
                    
                    card(
                        title: "Tankstellen",
                        colors: [Color.orange, Color.yellow],
                        systemImage: "fuelpump.fill"
                    )
                    
                    card(
                        title: "Parkplätze",
                        colors: [Color.blue, Color.systemBlue],
                        systemImage: "parkingsign"
                    )
                    
                }
                .padding()
                
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Text("Entdecken"))
            
        }
        
    }
    
    @ViewBuilder
    func card(title: String, colors: [Color] = [], systemImage: String? = nil) -> some View {
        
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                
                Text(title)
                    .font(.headline.weight(.bold))
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
        .padding(12)
        .overlay(ZStack {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 50, maxHeight: 50)
                    .offset(x: 0, y: -10)
                    .opacity(0.5)
                    .rotationEffect(.degrees(-12))
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing))
        .background(LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(12)
        
    }
    
}

struct ExploreOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExploreOverview()
    }
}
