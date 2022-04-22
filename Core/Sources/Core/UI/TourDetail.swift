//
//  TourDetail.swift
//  
//
//  Created by Lennart Fischer on 09.01.22.
//

import SwiftUI

struct TourDetail: View {
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                
                Rectangle()
                    .fill(Color(UIColor.secondarySystemFill))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        ZStack(alignment: .bottomLeading) {
                            
                            HStack(alignment: .bottom) {
                                
                                Text("Entry Tour")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button {
                                    
                                } label: {
                                    
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 60, height: 60, alignment: .center)
                                        .overlay(
                                            Image(systemName: "location.fill")
                                                .foregroundColor(.black)
                                        )
                                    
                                }
                                
                            }
                            
                        }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    )
                
                HStack(alignment: .top, spacing: 20) {
                    
                    // swiftlint:disable:next line_length
                    Text("Moers has so many things to do that you will want to spend at least a few days exploring the city. Popular attractions range from impressive architecture and poignant reminders of 20th-century history to a vibrant cultural and entertainment scene. A highlight of a walk around Moers's lovely pedestrian-friendly cobbled streets.")
                    
                    VStack(spacing: 20) {
                        
                        attribute(value: "1", label: "h")
                        
                        attribute(value: "21", label: "km")
                        
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    
                }
                .padding()
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.tertiarySystemFill))
                    .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                    .padding()
                
            }
            
        }
        .ignoresSafeArea(.container, edges: .top)
        
    }
    
    @ViewBuilder
    private func attribute(value: String, label: String) -> some View {
        
        VStack {
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
            
        }
        
    }
    
}

struct TourDetail_Previews: PreviewProvider {
    static var previews: some View {
        TourDetail()
            .preferredColorScheme(.dark)
    }
}
