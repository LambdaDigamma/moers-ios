//
//  EventList.swift
//  moers festival Watch App
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct EventList: View {
    
    @State var data = ["ABC", "DEF", "GHI", "JKL"]
    
    var body: some View {
        
        NavigationStack {
            
            List(data, id: \.self, rowContent: { (data) in
                Text(data)
            })
            .navigationTitle(Text("Events"))
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
    
}

struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        EventList()
    }
}
