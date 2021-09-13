//
//  AppView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct AppView: View {
    
//    @State private var selection: Tab = .dashboard
    @State var selection: Set<Int> = [0]
    
    var body: some View {
        
//        if false {
            
            return TabView(selection: $selection) {
                
                NavigationView {
                    DashboardView()
                }
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Dashboard")
                }
                .tag(Tab.dashboard)
                
                NavigationView {
                    NewsView()
                }
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("News")
                }
                .tag(Tab.news)
                
            }
            .background(Color("TabBar"))
            .accentColor(Color("Accent"))
            
//        } else {
//            return NavigationView {
//
//                List(selection: self.$selection) {
//
//                    NavigationLink(destination: DashboardView()) {
//                        Label("Dashboard", systemImage: "gauge")
//                    }
//                    .tag(0)
//
//                    NavigationLink(destination: NewsView()) {
//                        Label("News", systemImage: "newspaper")
//                    }.tag(1)
//
//                    NavigationLink(destination: MapView()) {
//                        Label("Map", systemImage: "map")
//                    }.tag(2)
//
//                    NavigationLink(destination: EventsView()) {
//                        Label("Events", systemImage: "calendar")
//                    }.tag(3)
//
//                    NavigationLink(destination: OtherView()) {
//                        Label("Other", systemImage: "list.triangle")
//                    }.tag(4)
//
//                }
//                .listStyle(SidebarListStyle())
//                .accentColor(Color("Accent"))
//                .navigationTitle("Mein Moers")
//
//
//            }.accentColor(Color("Accent"))
//        }
        
    }
}

@available(iOS 14.0, *)
extension AppView {
    enum Tab {
        case dashboard
        case news
        case map
        case events
        case other
    }
}

@available(iOS 14.0, *)
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppView()
            AppView().environment(\.colorScheme, .dark)
        }
    }
}
