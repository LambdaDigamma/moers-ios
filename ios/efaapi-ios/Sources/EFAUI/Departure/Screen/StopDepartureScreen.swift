//
//  StopDepartureScreen.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import EFAAPI
import SwiftUI
import Factory

public struct StopDepartureScreen: View {
    
    @StateObject var viewModel = StopDepartureViewModel()
    @State var showStationSearch: Bool = false
    
    @Injected(\.transitService) private var transitService
    
    public init() {
        
    }
    
    public var body: some View {
        
        ScrollView {
            
            VStack {
                
                Button(action: {
                    searchStation()
                }) {
                    
                    if let currentStop = viewModel.currentStop {
                        Text(currentStop.name)
                    } else {
                        Text("Haltestelle auswählen")
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .sheet(isPresented: $showStationSearch) {
            TransitLocationSearchScreen()
        }
        
    }
    
    private func searchStation() {
        
        showStationSearch = true
        
    }
    
}

struct StopDepartureScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        StopDepartureScreen()
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
    }
}
