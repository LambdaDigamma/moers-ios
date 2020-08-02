//
//  DashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import MMAPI

@available(iOS 13.0, *)
struct DashboardView: View {
    
    
    init(rubbishItems: [RubbishPickupItem] = []) {
        self.rubbishItems = Array(rubbishItems.prefix(3))
    }
    
    var rubbishItems: [RubbishPickupItem] = []
    
    var body: some View {
        ScrollView {
            
            PetrolDashboardView(rubbishItems: rubbishItems)
            
        }
        .background(Color("Background"))
        .accentColor(Color("Accent"))
        .navigationBarTitle(Text("Dashboard"), displayMode: .automatic)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


#if DEBUG
var schedule: [RubbishPickupItem] = [
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .organic),
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .plastic),
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .paper)
]
#endif

@available(iOS 13.0, *)
struct DashboardView_Previews: PreviewProvider {
    
    
    
    static var previews: some View {
        Group {
            DashboardView(rubbishItems: schedule)
            DashboardView(rubbishItems: schedule)
                .environment(\.colorScheme, .dark)
        }
        
    }
}
