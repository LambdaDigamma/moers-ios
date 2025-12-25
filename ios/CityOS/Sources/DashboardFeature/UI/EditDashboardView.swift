//
//  EditDashboardView.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import SwiftUI
import Core

struct EditDashboardView: View {
    
    @State private var items = ["Fuel overview", "Waste calendar", "Parking Lots"]
    
    var body: some View {
        
        List {
            
            Section {
                
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onMove(perform: move)
                
            }
            
            Section {
                Button(action: {}) {
                    Text("Add")
                }
            }
            
        }
        
    }
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
}

struct EditDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        EditDashboardView()
            .preferredColorScheme(.dark)
    }
}
