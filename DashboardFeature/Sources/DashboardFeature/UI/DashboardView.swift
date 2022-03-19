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
    
    @StateObject var viewModel: DashboardViewModel = .init(
        loader: DashboardConfigDiskLoader()
    )
    
    @StateObject var fuelViewModel = PetrolPriceDashboardViewModel()
    @StateObject var rubbishViewModel = RubbishDashboardViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        
        GeometryReader { geo in
            
            ScrollView {
                
                LazyVGrid(columns: columns(for: geo.size), spacing: 20) {
                    
                    ForEach(viewModel.displayables, id: \.id) { item in
                        dashboardItem(for: item)
                    }
                    
                }
                .padding()
                
            }
            
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
        .navigationBarTitle(PackageStrings.Dashboard.title)
        .onAppear {
            UserActivity.current = UserActivities.configureDashboardActivity()
            viewModel.load()
        }
        
    }
    
    @ViewBuilder
    func dashboardItem(
        for item: DashboardItemConfigurable
    ) -> some View {
        
        if item is RubbishDashboardConfiguration {
            
            NavigationLink {
                RubbishScheduleList()
            } label: {
                RubbishDashboardPanel(viewModel: rubbishViewModel)
                    .foregroundColor(.primary)
            }
            
        } else if item is PetrolDashboardConfiguration {
            
            PetrolPriceDashboardView(viewModel: fuelViewModel)
            
        }
        
    }
    
    private func columns(for size: CGSize) -> [GridItem] {
        
        return Array(
            repeating: GridItem(.flexible(minimum: 100, maximum: 600),
                                spacing: 16,
                                alignment: .topTrailing),
            count: size.width > 1000 ? 3 : (size.width > 600 ? 2 : 1)
        )
        
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
