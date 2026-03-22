//
//  ExtendedDayEventsView.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import SwiftUI

public struct ExtendedDayEventsView: View {
    
    private let day: TimetableDay
    private let isFilterActive: Bool
    
    @EnvironmentObject private var transmitter: TimetableTransmitter
    
    public init(
        day: TimetableDay,
        isFilterActive: Bool
    ) {
        self.day = day
        self.isFilterActive = isFilterActive
    }
    
    public var body: some View {
        
        ZStack {
            
            if day.events.isEmpty && isFilterActive {
                VStack(spacing: 16) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(EventPackageStrings.noEventsForFilter)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            } else {
                
                ScrollView{
                    LazyVStack {
                        
                        ForEach(day.events) { event in
                            
                            Button(action: {
                                if let eventID = event.eventID {
                                    transmitter.dispatchShowEvent(eventID)
                                }
                            }) {
                                
                                EventCard(viewModel: event)
                                
                                
                            }
                            
                        }
                        
                    }
                    .padding()
                }
                
            }
            
        }
        
    }
    
}
