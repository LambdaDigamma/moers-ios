//
//  DashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import MMAPI
import ModernNetworking

public struct DashboardView: View {
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
//                RubbishPanel()
                
            }
            .padding()
            
        }
        .navigationBarTitle(Text("DashboardTabItem"))
        
    }
    
}

var schedule: [RubbishPickupItem] = [
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .organic),
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .plastic),
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .paper)
]

public struct RubbishPanel: View {
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack {

                RubbishDashboardPanel(items: .success(schedule))
                
            }
            
        }
        
    }
    
}

@available(iOS 13.0, *)
struct DashboardView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
                DashboardView()
            }
            .environment(\.locale, .init(identifier: "de"))
        }
    }
    
}
