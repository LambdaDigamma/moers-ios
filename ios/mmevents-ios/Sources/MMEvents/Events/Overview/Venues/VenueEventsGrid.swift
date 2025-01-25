//
//  VenueEventsGrid.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

struct VenueEventsGrid: View {
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                
                HStack(alignment: .top, spacing: 2) {
                    
                    
                    
                    Divider()
                    
                    venueTimeline(title: "ENNI Eventhalle")
                    
                    Divider()
                    
                    venueTimeline(title: "Am Viehtheater")
                    
                    Divider()
                    
                    venueTimeline(title: "ENNI Eventhalle")
                    
                }
                .frame(minHeight: proxy.size.height, maxHeight: .infinity, alignment: .topLeading)
                
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            
        }
        
    }
    
    @ViewBuilder
    func times() -> some View {
        
        
        
    }
    
    @ViewBuilder
    func venueTimeline(title: String) -> some View {
        
        VStack {
            
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .padding(.horizontal)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(Color.tertiarySystemFill)
            
            
        }
        .frame(minWidth: 200, maxHeight: .infinity, alignment: .topLeading)
        
    }
    
}

struct VenueEventsGrid_Previews: PreviewProvider {
    static var previews: some View {
        VenueEventsGrid()
            .preferredColorScheme(.dark)
    }
}
