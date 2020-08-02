//
//  Sidebar.swift
//  Moers
//
//  Created by Lennart Fischer on 28.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct Sidebar: View {
    var body: some View {
        List(1..<100) { i in
            Image(systemName: "calendar")
            Text("Row \(i)").listItemTint(Color("Accent"))
        }
        .listStyle(SidebarListStyle())
    }
}

@available(iOS 14.0, *)
struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}
