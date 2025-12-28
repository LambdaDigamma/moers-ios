//
//  ParkingDashboardView.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

import SwiftUI
import Core

public struct ParkingDashboardView: View {
    
    @ObservedObject var viewModel: ParkingDashboardViewModel
    
    public init(viewModel: ParkingDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        CardPanelView {
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: 16) {
                    
                    Rectangle()
                        .fill(Color.blue)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 24)
                        .overlay(ZStack {
                            Image(systemName: "parkingsign")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .padding(6)
                        })
                        .cornerRadius(4)
                        .accessibilityHidden(true)
                    
                    Group {
                        Text("Free parking spaces", bundle: .module)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }.lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                Divider()
                
                viewModel.parkingAreas.isLoading {
                    areasTable(parkingAreas: .dashboardPlaceholder())
                        .redacted(reason: .placeholder)
                }
                
                viewModel.parkingAreas.hasResource { (data: ParkingDashboardViewData) in
                    VStack(spacing: 0) {
                        areasTable(parkingAreas: data.parkingAreas)
                        
                        if data.isOutOfDate {
                            outOfDateWarning(data: data)
                        }
                    }
                }
                
                viewModel.parkingAreas.hasError { (error: Error) in
                    Text(error.localizedDescription)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .task {
            viewModel.load()
        }
        
    }
    
    @ViewBuilder
    private func areasTable(parkingAreas: [ParkingArea]) -> some View {
        
        let pairs = parkingAreas.chunked(into: 2)
        
        VStack(spacing: 0) {
            
            ForEach(Array(pairs.enumerated()), id: \.offset) { (index, pair) in
                
                if let first = pair.first {
                    if pair.count == 2, let last = pair.last {
                        row(firstArea: first, secondArea: last)
                    } else {
                        row(firstArea: first, secondArea: nil)
                    }
                }
                
                if (index != pairs.count - 1) {
                    Divider()
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func areasGrid() -> some View {
        
        LazyVGrid(columns: [
            GridItem(spacing: 16),
            GridItem(spacing: 16)
        ], spacing: 12) {
            parkingAreaDetail(name: "Kautzstr.", freeSites: 20)
            parkingAreaDetail(name: "Kastell", freeSites: 21)
            parkingAreaDetail(name: "Braun", freeSites: 108)
            parkingAreaDetail(name: "Mühlenstr.", freeSites: 202)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .clipShape(ContainerRelativeShape())
        
    }
    
    @ViewBuilder
    private func parkingAreaDetail(name: String, freeSites: Int) -> some View {
        
        HStack {
            
            Text(name)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(freeSites)")
                .font(.system(.footnote, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .foregroundColor(.primary)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(4)
            
        }
        
    }
    
    @ViewBuilder
    private func row(
        firstArea: ParkingArea,
        secondArea: ParkingArea?
    ) -> some View {
        
        HStack(spacing: 0) {
            
            parkingAreaDetail(name: firstArea.name, freeSites: firstArea.freeSites)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            
            Divider()
                .frame(minHeight: 0, maxHeight: 40)
            
            if let secondArea = secondArea {
                
                parkingAreaDetail(name: secondArea.name, freeSites: secondArea.freeSites)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            
        }
        
    }
    
    @ViewBuilder
    private func outOfDateWarning(data: ParkingDashboardViewData) -> some View {
        
        Divider()
        
        VStack {
            
            Text(
                "The data is no longer up to date. (\(data.minimalLastUpdate.formatted(.dateTime.day().month().year())))",
                bundle: .module
            )
            .font(.caption.weight(.medium))
            
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.red)
        .foregroundColor(.white)
        
    }
    
}

public extension Collection where Element == ParkingArea {
    
    static func dashboardPlaceholder() -> [ParkingArea] {
        return [
            ParkingArea(id: 1, name: "Kautzstr.", capacity: 62, occupiedSites: 44),
            ParkingArea(id: 2, name: "Bankstr.", capacity: 139, occupiedSites: 6),
            ParkingArea(id: 3, name: "Kastell", capacity: 200, occupiedSites: 155),
            ParkingArea(id: 4, name: "Mühlenstraße", capacity: 699, occupiedSites: 109),
            ParkingArea(id: 5, name: "Braun", capacity: 222, occupiedSites: 74),
            ParkingArea(id: 6, name: "C&A", capacity: 95, occupiedSites: 47),
            ParkingArea(id: 7, name: "Neuer Wall", capacity: 139, occupiedSites: 70),
            ParkingArea(id: 8, name: "F. Ebert-Platz", capacity: 299, occupiedSites: 65),
            ParkingArea(id: 9, name: "Altstadt", capacity: 103, occupiedSites: 35),
        ]
    }
    
}

struct ParkingDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = ParkingDashboardViewModel(parkingService: StaticParkingService(
            oldData: true
        ))
        
        ParkingDashboardView(viewModel: viewModel)
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
