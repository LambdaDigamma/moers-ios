//
//  DashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 20.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import RubbishFeature

public struct DashboardView: View {
    
    @StateObject var viewModel: DashboardViewModel = .init(loader: DashboardConfigDiskLoader())
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
                ForEach(viewModel.displayables, id: \.id) { item in
                    dashboardItem(for: item)
                }
                
            }
            .padding()
            
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
        
        if let rubbishItem = item as? RubbishDashboardConfiguration {
            Text("Rubbish")
        } else if let petrolItem = item as? PetrolDashboardConfiguration {
            Text("Petrol")
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
