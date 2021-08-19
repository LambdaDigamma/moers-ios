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
        
//        List {
//            Text("Test")
//        }
//        .listStyle(InsetGroupedListStyle())
        
        
        ScrollView {
            
            LazyVStack {
                
                RubbishPanel()
                
//                Text("Placeholder")
//                    .padding()
////                    .background(Color.systemGroupedBackground)
//                    .background(Color.secondarySystemGroupedBackground)
////                    .background(Color.systemGroupedBackground)
                
            }
            .padding()
            
        }
        .navigationBarTitle(Text("DashboardTabItem"))
        
    }
    
//    init(rubbishItems: [RubbishPickupItem] = []) {
//        self.rubbishItems = Array(rubbishItems.prefix(3))
//    }
//
//    var rubbishItems: [RubbishPickupItem] = []
//
//    var body: some View {
//        ScrollView {
//
//            RubbishDashboardView(items: .success([RubbishPickupItem(date: .somedayInFuture, type: .paper)]))
//
//        }
//        .background(Color("Background"))
//        .accentColor(Color("Accent"))
//        .navigationBarTitle(Text("DashboardTabItem"), displayMode: .automatic)
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
}

var schedule: [RubbishPickupItem] = [
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .organic),
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .plastic),
    RubbishPickupItem(date: Date(timeIntervalSinceNow: 60 * 120), type: .paper)
]

public struct RubbishPanel: View {
    
    public var body: some View {
        
        VStack {
            Text("Test")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(20)
        
    }
    
    @ViewBuilder
    public func rubbishRow() -> some View {
        
    }
    
}

@available(iOS 13.0, *)
struct DashboardView_Previews: PreviewProvider {
    
    
    
    static var previews: some View {
        Group {
            NavigationView {
                DashboardView()
//                DashboardView(rubbishItems: schedule)
            }
            .environment(\.locale, .init(identifier: "de"))
//            NavigationView {
//                DashboardView(rubbishItems: schedule)
//            }
//            .environment(\.colorScheme, .dark)
        }
        
    }
}
