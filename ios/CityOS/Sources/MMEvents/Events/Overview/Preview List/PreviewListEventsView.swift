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
            
            List {
                
                ForEach(viewModel.events) { event in
                    Button(action: {
                        if let eventID = event.eventID {
                            transmitter.dispatchShowEvent(eventID)
                        }
                    }) {
                        EventListItem(viewModel: event)
                    }
                    .accessibilityIdentifier("Event-Row-\(event.eventID ?? 0)")
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
