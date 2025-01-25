//
//  ExtendedDayEventsView.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import SwiftUI

public struct ExtendedDayEventsView: View {
    
    private let date: Date
    
    @StateObject var viewModel: DayEventsViewModel
    @EnvironmentObject var transmitter: TimetableTransmitter
    
    public init(date: Date) {
        self.date = date
        self._viewModel = StateObject(wrappedValue: DayEventsViewModel(date: date))
    }
    
    public var body: some View {
        
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
        .task {
            await viewModel.reload()
        }
        
    }
    
}
