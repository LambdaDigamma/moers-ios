//
//  ExtendedDayEventsView.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import SwiftUI

public struct ExtendedDayEventsView: View {
    
    private let date: Date
    
    @ObservedObject var viewModel: DayEventsViewModel
    @EnvironmentObject var transmitter: TimetableTransmitter
    
    public init(viewModel: DayEventsViewModel) {
        self.date = viewModel.date
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ZStack {
            
            if viewModel.events.isEmpty && !viewModel.filter.isEmpty {
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
                        
                        ForEach(viewModel.events) { event in
                            
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
