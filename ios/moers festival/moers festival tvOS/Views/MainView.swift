//
//  MainView.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 13.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            VideoListView()
                .tabItem {
                    Image(systemName: "tv.music.note.fill")
                    Text("Videos")
                }
                .tag(0)
            
            PlayerView()
                .tabItem {
                    Image(systemName: "play.fill")
                    Text("Live")
                }
                .tag(1)
            
        }
        .navigationTitle("moers festival")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
