//
//  ActiveTripScreen.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import SwiftUI
import CoreLocation
import Combine
import Core
import Factory

public struct ActiveTripScreen: View {
    
    @State var showConfigureTrip = false
    
    public let accent: Color = .yellow
    public let onAccent: Color = .black
    
    @StateObject var viewModel = ActiveTripViewModel()
    
    public var body: some View {
        
        ZStack {
            
            viewModel.trip.isLoading {
                DefaultProgressView(text: "Loading your trip…")
            }
            
            viewModel.trip.hasResource { data in
                ActiveTripContainer(data: data)
            }
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                Button(action: {
                    showConfigureTrip = true
                }) {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundColor(accent)
                }
                
                Menu {
                    Button(action: {
                        viewModel.terminate()
                    }) {
                        Text("Beenden")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(accent)
                }
                
            }
        }
        .onAppear {
            viewModel.load()
        }
        .sheet(isPresented: $showConfigureTrip) {
            TripConfigurationScreen(viewModel: viewModel.search)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text(""))
        
    }
    
}

public struct ActiveTripContainer: View {
    
    public let isBoardedTrain = true
    
    public let accent: Color = .yellow
    public let onAccent: Color = .black
    
    private let data: ActiveTripData
    
    public init(data: ActiveTripData) {
        self.data = data
    }
    
    public var body: some View {
        
//        NavigationDirectionsView(data: .init(
//            source: Point(latitude: 51.45208, longitude: 6.62323),
//            destination: Point(latitude: 51.45081, longitude: 6.64163)
//        ))
//        .frame(maxWidth: .infinity, minHeight: 500, maxHeight: 500)

        ScrollView {

            LazyVStack {

//                top()
//                    .padding(.bottom, 60)

                if !isBoardedTrain {
                    trackView()
                        .padding(.bottom, 80)
                } else {
                    inTrain()
                        .padding()
                        .padding(.bottom, 40)
                }

//                timeInformation()

//                Divider()
//                    .padding()
//
//                actions()

            }
            .padding(.top)

        }
        .background(
            LinearGradient(colors: [
                Color(hex: "13151A"),
                Color(hex: "1C1E23")
            ], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
        )
        
    }
    
    @ViewBuilder
    private func top() -> some View {
        
        VStack(spacing: 12) {
            
            //            Text("\(origin) \(Image(systemName: "arrow.right")) \(destination)")
            //                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                
                Text("\(Image(systemName: "tram.fill")) RE5")
                
                Text("\(Image(systemName: "wifi")) WI-FI")
                
            }
            .font(.callout.weight(.semibold))
            .foregroundColor(.secondary)
            
        }
        
    }
    
    @ViewBuilder
    private func trackView() -> some View {
        
        BigTrackBadge(track: "11", accent: accent, onAccent: onAccent)
        
    }
    
    @ViewBuilder
    private func inTrain() -> some View {
        
        InTrainMap()
        
    }
    
    @ViewBuilder
    private func timeInformation() -> some View {
        
        let plannedDeparture: Date = Date(timeIntervalSinceNow: 60 * 5)
        let realtimeDeparture: Date = Date(timeIntervalSinceNow: 60 * 9)
        let plannedArrival: Date = Date(timeIntervalSinceNow: 60 * 60)
        let realtimeArrival: Date = Date(timeIntervalSinceNow: 60 * 63)
        
        TimeInformation(
            accentColor: accent,
            onAccent: onAccent,
            plannedDeparture: plannedDeparture,
            realtimeDeparture: realtimeDeparture,
            plannedArrival: plannedArrival,
            realtimeArrival: realtimeArrival,
            isBoardedTrain: isBoardedTrain
        )
        .padding()
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        if !isBoardedTrain {
            Button(action: {}) {
                Text(PackageStrings.ActiveTrip.checkIntoTrain)
                    .foregroundColor(accent)
            }
        }
        
    }
    
}


struct ActiveTripScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActiveTripScreen(
//                origin: "Duisburg, Hbf",
//                destination: "Aachen, Hbf"
            )
        }.preferredColorScheme(.dark)
    }
}
