//
//  TripDetailScreen.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Foundation
import SwiftUI
import Combine
import EFAAPI

public struct TripDetailScreen: View {
    
    @StateObject var viewModel: TripDetailViewModel
    
    private let onActivateRoute: () -> Void
    
    public init(
        route: RouteUiState,
        onActivateRoute: @escaping () -> Void = {}
    ) {
        
        let viewModel = TripDetailViewModel(
            route: route
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
        self.onActivateRoute = onActivateRoute
        
    }
    
    public init(
        onActivateRoute: @escaping () -> Void = {}
    ) {
        
        let viewModel = TripDetailViewModel()
        
        self._viewModel = .init(wrappedValue: viewModel)
        self.onActivateRoute = onActivateRoute
        
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            scrollingView()
            
            bottomBar()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    @ViewBuilder
    private func topInfo() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.startDate, style: .date)
            
            Group {
                Text(viewModel.origin) + Text(" - ") + Text(viewModel.destination)
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            
            Divider()
            
            Text("Dauer: \(viewModel.duration) | \(viewModel.numberOfChanges) Umst.")
                .font(.callout)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        Divider()
        
        VStack {
            
            Button(action: {
                onActivateRoute()
            }) {
                Text("Verbindung aktivieren (bald)")
            }
            .buttonStyle(EfaPrimaryButtonStyle())
            
            Text("Dauer: \(viewModel.duration) | \(viewModel.numberOfChanges) Umst.")
                .font(.callout.weight(.medium))
                .foregroundColor(.secondary)
            
        }
        .padding()
        
    }
    
    @ViewBuilder
    private func scrollingView() -> some View {
        
        ScrollView {
            
            LazyVStack(spacing: 0) {
                
                topInfo()
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .padding(.bottom, 40)
                
                ForEach(viewModel.partialRoutes) { (partialRoute: PartialRouteUiState) in
                    
                    if partialRoute.transportType == .footpath {
                        
                        FootPathView(
                            name: partialRoute.to.stationName,
                            time: partialRoute.from.targetDate,
                            durationInMinutes: partialRoute.timeInMinutes,
                            distance: partialRoute.distance
                        )
                        
                    } else {
                        
                        PartialRouteView(
                            from: partialRoute.from,
                            to: partialRoute.to,
                            line: partialRoute.line,
                            lineDestination: partialRoute.lineDestination,
                            transportType: partialRoute.transportType
                        )
                        
                        if let _ = partialRoute.footPathAfter {
                            ChangePlatformView()
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

struct TripDetailScreen_Previews: PreviewProvider {
    
    static let start = Date(timeIntervalSinceNow: 60 * 5)
    
    static let routeState = RouteUiState(
        origin: "Mönchengladbach, Königstraße 13",
        destination: "Aachen, Ahornstraße 55",
        date: Date(timeIntervalSinceNow: 0),
        duration: "01:30",
        numberOfChanges: 2,
        partialRoutes: [
            .init(
                transportType: .footpath,
                from: .init(
                    stationName: "Mönchengladbach, Königstraße 13",
                    targetDate: start,
                    realtimeDate: nil,
                    platform: ""
                ),
                to: .init(
                    stationName: "MG Marienplatz",
                    targetDate: start.addingTimeInterval(16 * 60),
                    realtimeDate: nil,
                    platform: "8"
                ),
                timeInMinutes: 16,
                distance: 1_032,
                line: "",
                lineDestination: ""
            ),
            .init(
                transportType: .cityBus,
                from: .init(
                    stationName: "MG Marienplatz",
                    targetDate: start.addingTimeInterval(16 * 60),
                    realtimeDate: start.addingTimeInterval(18 * 60),
                    platform: "8"
                ),
                to: .init(
                    stationName: "MG Rheydt Hbf",
                    targetDate: start.addingTimeInterval(17 * 60),
                    realtimeDate: start.addingTimeInterval(19 * 60),
                    platform: "9"
                ),
                timeInMinutes: 16,
                distance: nil,
                line: "016",
                lineDestination: "Mönchengladb. Wickrath Markt",
                footPathAfter: .init(text: "")
            ),
            .init(
                transportType: .regionalTrain,
                from: .init(
                    stationName: "MG Rheydt Hbf",
                    targetDate: start.addingTimeInterval(31 * 60),
                    realtimeDate: start.addingTimeInterval(31 * 60),
                    platform: "3"
                ),
                to: .init(
                    stationName: "Aachen, West Bf",
                    targetDate: start.addingTimeInterval((31 + 36) * 60),
                    realtimeDate: start.addingTimeInterval((31 + 36) * 60),
                    platform: "1"
                ),
                timeInMinutes: 36,
                distance: nil,
                line: "RE4",
                lineDestination: "Aachen, Hbf"
            ),
            .init(
                transportType: .footpath,
                from: .init(
                    stationName: "Aachen, West Bf",
                    targetDate: start.addingTimeInterval((31 + 36 + 16) * 60),
                    realtimeDate: nil,
                    platform: "1"
                ),
                to: .init(
                    stationName: "Aachen, Westbahnhof (Bus)",
                    targetDate: start.addingTimeInterval((31 + 36 + 26) * 60),
                    realtimeDate: nil,
                    platform: ""
                ),
                timeInMinutes: 5,
                distance: 230,
                line: "",
                lineDestination: ""
            ),
            .init(
                transportType: .cityBus,
                from: .init(
                    stationName: "Aachen, Westbahnhof (Bus)",
                    targetDate: start.addingTimeInterval((31 + 36 + 30) * 60),
                    realtimeDate: start.addingTimeInterval((31 + 36 + 30) * 60),
                    platform: "3"
                ),
                to: .init(
                    stationName: "Aachen, Halifaxstraße",
                    targetDate: start.addingTimeInterval((31 + 40 + 32) * 60),
                    realtimeDate: start.addingTimeInterval((31 + 40 + 32) * 60),
                    platform: "1"
                ),
                timeInMinutes: 2,
                distance: nil,
                line: "",
                lineDestination: "Campus Melaten - Vaals Busstandort"
            ),
        ]
    )
    
    static var previews: some View {
        
        Group {
            
            TripDetailScreen(route: routeState)
                .efaAccentColor(.yellow)
                .efaOnAccentColor(.black)
                .preferredColorScheme(.dark)
            
        }
        
    }
    
}
