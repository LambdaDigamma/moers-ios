//
//  DashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 20.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import RubbishFeature
import FuelFeature
import Resolver

public struct DashboardView: View {
    
    @StateObject var viewModel: DashboardViewModel = .init(loader: DashboardConfigDiskLoader())
    
    public init() {
        
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 20) {
                
                ForEach(viewModel.displayables, id: \.id) { item in
                    dashboardItem(for: item)
                }
                
            }
            .padding()
            
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {}) {
                    Image(systemName: "gear")
                        .foregroundColor(Color.yellow)
                }
                .foregroundColor(Color.yellow)
            }
        }
        .navigationBarTitle("Übersicht")
        .onAppear {
            viewModel.load()
        }
        
    }
    
    @ViewBuilder
    func dashboardItem(
        for item: DashboardItemConfigurable
    ) -> some View {
        
        if item is RubbishDashboardConfiguration {
            
//            let service = StaticRubbishService()
            let viewModel = RubbishDashboardViewModel(
                initialState: .success([
                    RubbishPickupItem(date: Date(timeIntervalSinceNow: 1 * 24 * 60 * 60), type: .organic),
                    RubbishPickupItem(date: Date(timeIntervalSinceNow: 2 * 24 * 60 * 60), type: .residual),
                    RubbishPickupItem(date: Date(timeIntervalSinceNow: 3 * 24 * 60 * 60), type: .paper),
                ])
            )
            
            RubbishDashboardPanel(viewModel: viewModel)
            
        } else if item is PetrolDashboardConfiguration {
            
            PetrolPriceDashboardView.init()
            
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
