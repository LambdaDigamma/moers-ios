//
//  CompactDayEventsView.swift
//  
//
//  Created by Lennart Fischer on 12.04.23.
//

import SwiftUI

public struct CompactDayEventsView: View {
    
    private let day: TimetableDay
    private let isFilterActive: Bool
    private let onRefresh: () async -> Void
    
    @EnvironmentObject private var transmitter: TimetableTransmitter
    
    public init(
        day: TimetableDay,
        isFilterActive: Bool,
        onRefresh: @escaping () async -> Void
    ) {
        self.day = day
        self.isFilterActive = isFilterActive
        self.onRefresh = onRefresh
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
            
                List {
                    
                    ForEach(day.events) { event in
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
                    await onRefresh()
                }
                
            }
            
        }
        
    }
    
}

//struct DayEventsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompactDayEventsView(date: Date())
//            .preferredColorScheme(.dark)
//    }
//}
