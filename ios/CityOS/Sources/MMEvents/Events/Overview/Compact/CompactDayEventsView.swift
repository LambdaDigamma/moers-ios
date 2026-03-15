//
//  CompactDayEventsView.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import SwiftUI

public struct CompactDayEventsView: View {
    
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
                .refreshable {
                    await viewModel.refresh()
                }
                
            }
            
        }
        .task {
            await viewModel.reload()
        }
        
    }
    
}

//struct DayEventsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompactDayEventsView(date: Date())
//            .preferredColorScheme(.dark)
//    }
//}
