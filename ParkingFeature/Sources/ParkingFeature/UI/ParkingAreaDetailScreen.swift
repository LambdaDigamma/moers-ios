//
//  ParkingAreaDetailScreen.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import SwiftUI
import Core
import MapKit
import Charts
import CoreLocation

public struct Marker: Identifiable {
    
    public let id: UUID = UUID()
    public let coordinate: CLLocationCoordinate2D
    
}

public struct ParkingAreaDetailScreen: View {
    
    @ObservedObject private var viewModel: ParkingAreaViewModel
    
    public init(viewModel: ParkingAreaViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ScrollView {
            
            VStack(spacing: 0) {
                
                header()
                
                availability()
                
                openingHours()
                
                prizeInformation()
                
                actions()
                
            }
            .frame(maxWidth: .infinity)
            
        }
        .toolbar {
            toolbar()
        }
        .onAppear {
            viewModel.load()
        }
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(alignment: .leading) {
            
            if let location = viewModel.location {
                
                let marker = Marker(coordinate: location.toCoordinate())
                
                Map(coordinateRegion: $viewModel.region, annotationItems: [marker]) { marker in
                    
                    MapMarker(coordinate: marker.coordinate, tint: Color.blue)
                    
                }
                    .frame(height: 200)
                
            }
            
            HStack(spacing: 16) {
                
                Rectangle()
                    .fill(ParkingColors.verkehrsblau)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .overlay(
                        Text("P")
                            .foregroundColor(.white)
                            .font(.largeTitle.weight(.bold))
                    )
                    .unredacted()
                
                VStack(alignment: .leading) {
                    
                    Text(viewModel.title)
                        .font(.title2.weight(.semibold))
                    
                    Text(viewModel.currentOpeningState.name)
                        .foregroundColor(.secondary)
                    
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private func availability() -> some View {
        
        Divider()
            .padding(.horizontal)
        
        VStack(alignment: .leading) {
            
            HStack {
                
                Text("Aktuelle Belegung")
                    .fontWeight(.semibold)
                    .unredacted()
                
                Spacer()
                
                HStack(spacing: 0) {
                    
                    Text("\(viewModel.free)") +
                    Text(" / \(viewModel.total)")
                        .foregroundColor(.secondary)
                    
                    Text(" frei")
                        .foregroundColor(.secondary)
                        .unredacted()
                    
                }
                
            }
            
            ProgressMeterView(value: viewModel.percentage, color: ParkingColors.verkehrsblau)
            
            Chart(data: [0.4, 0.45, 0.6, 0.8, 0.6, 0.9, 1, 0.8, 0.75, 0.4, 0.2, 0.1, 0.1, 0.3, 0.4, 0.45, 0.6, 0.8, 0.6, 0.9, 0.75, 0.6, 0.55, 0.5])
                .chartStyle(
//                    AreaChartStyle(
//                        .quadCurve,
//                        fill: LinearGradient(gradient: .init(colors: [
//                            ParkingColors.verkehrsblau.opacity(0.5),
//                            ParkingColors.verkehrsblau.opacity(0.7)
//                        ]), startPoint: .top, endPoint: .bottom)
//                      )
                    ColumnChartStyle(
                        column: Capsule().foregroundColor(ParkingColors.verkehrsblau),
                        spacing: 4
                    )
                )
                .frame(height: 80)
//                .cornerRadius(8)
                .padding(.top)
            
            HStack {
                
                Text("22:00")
                Spacer()
                Text("Jetzt")
                
            }
            .font(.caption2)
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func openingHours() -> some View {
        
        Divider()
            .padding(.horizontal)
        
        viewModel.openingHours.isLoading {
            
            OpeningHoursContainer(openingHours: [
                .init(text: "Mo-Fr", time: "09:00 - 19:00"),
                .init(text: "Sa", time: "10:00 - 16:00"),
            ])
                .redacted(reason: .placeholder)
                .padding()
            
        }
        
        viewModel.openingHours.hasResource { (entries: [OpeningHourEntry]) in
            
            OpeningHoursContainer(openingHours: entries)
                .padding()
            
        }
        
    }
    
    @ViewBuilder
    private func prizeInformation() -> some View {
        
        Divider()
            .padding(.horizontal)
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Preise")
                .fontWeight(.semibold)
                .padding(.bottom, 8)
                .unredacted()
            
            Text("Keine Preisinformationen")
                .foregroundColor(.secondary)
            
        }.padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        VStack {
            
            Button("Navigation starten", action: {})
                .buttonStyle(SecondaryButtonStyle())
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func toolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {}) {
                Image(systemName: "arrow.triangle.turn.up.right.circle")
            }
        }
        
    }
    
}

struct ParkingAreaDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = ParkingAreaViewModel(
            title: "Kauzstraße",
            free: 45,
            total: 200,
            currentOpeningState: .open,
            updatedAt: Date(timeIntervalSinceNow: -2 * 60)
        )
        
        ParkingAreaDetailScreen(viewModel: viewModel)
            .preferredColorScheme(.dark)
        
//        ParkingAreaDetailScreen(viewModel: viewModel)
        
    }
}
