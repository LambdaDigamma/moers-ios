//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 16.12.22.
//

import SwiftUI
import Combine
import CoreLocation
import Core
import Factory

struct InTrainMap: View {
    
    public let accent: Color = .yellow // .init(hex: "E16335")
    public let onAccent: Color = .black
    
    @StateObject var viewModel: InTrainMapViewModel = .init()
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            HStack(alignment: .top) {
                
                if let place = viewModel.currentPlace {
                    
                    Pill(
                        text: Text("\(Image(systemName: "location.fill")) \(place)"),
                        background: accent
                    )
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(onAccent)
                    .offset(x: 0, y: 6)
                    
                }
                
                Spacer()
                
                if let speed = viewModel.currentSpeed {
                    
                    if #available(iOS 15.0, *) {
                        Pill(
                            text: Text("\(Image(systemName: "speedometer")) \(speed)"),
                            background: accent
                        )
                        .monospacedDigit()
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(onAccent)
                        .offset(x: 0, y: 6)
                    } else {
                        Pill(
                            text: Text("\(Image(systemName: "speedometer")) \(speed)"),
                            background: accent
                        )
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(onAccent)
                        .offset(x: 0, y: 6)
                    }
                    
                }
                
//                BigTrackBadge(
//                    track: "11",
//                    accent: accent,
//                    onAccent: onAccent
//                )
//                .shadow(color: accent.opacity(0.5), radius: 6)
                
            }
            .zIndex(20)
            .padding(.horizontal)
            .offset(x: 0, y: -20)
            
            
            VStack(spacing: 0) {
                
                TripPartialRouteMap(
                    viewModel: viewModel
                )
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                
                
//                MapSnapshotView(
//                    location: CLLocationCoordinate2D(
//                        latitude: 51,
//                        longitude: 26
//                    ),
//                    span: 0.5
//                )
//                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                
                NextStops()
                
            }
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(12)
            
        }
        .task {
//            viewModel.start()
            viewModel.load()
        }
        .onDisappear {
            viewModel.stop()
        }
        
    }
    
}

struct InTrainMap_Previews: PreviewProvider {
    static var previews: some View {
        InTrainMap()
            .padding()
            .preferredColorScheme(.dark)
    }
}
