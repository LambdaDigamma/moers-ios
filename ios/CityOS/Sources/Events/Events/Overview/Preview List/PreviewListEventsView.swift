//
//  PreviewListEventsView.swift
//
//
//  Created by Lennart Fischer on 07.03.24.
//

import SwiftUI

struct PreviewListEventsView: View {
    
    @State private var viewModel = PreviewListEventsViewModel()
    @Environment(TimetableTransmitter.self) var transmitter: TimetableTransmitter
    
    public init() {
    }
    
    public var body: some View {
        
        ZStack {
            
            List(selection: Binding<Event.ID?>(
                get: { transmitter.selectedEventID },
                set: { eventID in
                    if let eventID { transmitter.dispatchShowEvent(eventID) }
                }
            )) {
                
                ForEach(viewModel.events) { event in
                    if let eventID = event.eventID {
                        EventListItem(viewModel: event)
                            .tag(eventID)
                            .accessibilityIdentifier("Event-Row-\(eventID)")
                    } else {
                        EventListItem(viewModel: event)
                            .accessibilityIdentifier("Event-Row-0")
                    }
                }
                
            }
            .listStyle(.plain)
            
        }
        .task {
            await viewModel.reload()
        }
        .onDisappear {
            viewModel.cancel()
        }
        
    }
    
}
