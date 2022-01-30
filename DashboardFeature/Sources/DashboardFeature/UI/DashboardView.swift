//
//  DashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 20.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Core
import SwiftUI
import FuelFeature
import RubbishFeature
import ParkingFeature
import Resolver

public struct DashboardView: View {
    
    @StateObject var viewModel: DashboardViewModel = .init(loader: DashboardConfigDiskLoader())
    
    public init() {
        
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 20) {
                
                #if DEBUG
                
                NavigationLink(destination: {
                    
                    ParkingAreaList(parkingService: Resolver.resolve())
                    
                }, label: {
                    EmergencyCard(text: "Bombenentschärfung in Moers-Meerbusch")
                        .cornerRadius(16)
                })
                
                #endif
                
                ForEach(viewModel.displayables, id: \.id) { item in
                    dashboardItem(for: item)
                }
                
            }
            .padding()
            
        }
        .toolbar {
//            ToolbarItem(placement: .primaryAction) {
//                Button(action: {}) {
//                    Image(systemName: "gear")
//                        .foregroundColor(Color.yellow)
//                }
//                .foregroundColor(Color.yellow)
//            }
        }
        .navigationBarTitle("Heute")
        .onAppear {
            viewModel.load()
        }
        
    }
    
    @ViewBuilder
    func dashboardItem(
        for item: DashboardItemConfigurable
    ) -> some View {
        
        if item is RubbishDashboardConfiguration {
            
            let viewModel = RubbishDashboardViewModel()
            
            RubbishDashboardPanel(viewModel: viewModel)
            
        } else if item is PetrolDashboardConfiguration {
            
            let viewModel = PetrolPriceDashboardViewModel()
            
            PetrolPriceDashboardView(viewModel: viewModel)
            
        }
        
    }
    
}

struct DashboardView_Previews: PreviewProvider {
    
    static var schedule: [RubbishPickupItem] = [
        RubbishPickupItem(
            date: Date(timeIntervalSinceNow: 60 * 120),
            type: .organic
        ),
        RubbishPickupItem(
            date: Date(timeIntervalSinceNow: 60 * 120),
            type: .plastic
        ),
        RubbishPickupItem(
            date: Date(timeIntervalSinceNow: 60 * 120),
            type: .paper
        )
    ]
    
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
    }
}
