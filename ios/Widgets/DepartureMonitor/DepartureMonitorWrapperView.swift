//
//  DepartureMonitorWrapperView.swift
//  Moers
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import WidgetKit
import SwiftUI
import EFAAPI
import EFAUI

struct DepartureMonitorWrapperView: View {
    
    var entry: DepartureMonitorEntry
        
    var body: some View {
        
        DepartureMonitorView(
            viewModel: .init(
                stationName: entry.name,
                departures: entry.departures
            )
        ).preferredColorScheme(.dark)
        
    }
    
}

struct DepartureMonitorWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        
        let entry = DepartureMonitorEntry(
            date: Date(timeIntervalSinceNow: -60 * 8),
            name: "Duisburg Hbf",
            departures: [
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.actualDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 2)))
                        .setting(\.servingLine.direction, to: "Münster (Westf) Hbf")
                        .setting(\.servingLine.symbol, to: "S1")
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 5)))
                        .setting(\.servingLine.direction, to: "Dortmund Hbf")
                        .setting(\.servingLine.symbol, to: "ICE 933")
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 10)))
                        .setting(\.servingLine.direction, to: "Rheurdt Kirche")
                        .setting(\.servingLine.symbol, to: "SB 30")
                        .setting(\.platformName, to: "1")
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 20)))
                        .setting(\.servingLine.direction, to: "Duisburg Ruhrau")
                        .setting(\.servingLine.symbol, to: "RE 1")
                )
                
            ])
        
        DepartureMonitorWrapperView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.locale, Locale(identifier: "de"))
        
        DepartureMonitorWrapperView(entry: entry)
            .environment(\.locale, Locale(identifier: "de"))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        DepartureMonitorWrapperView(entry: entry)
            .environment(\.locale, Locale(identifier: "de"))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .redacted(reason: .placeholder) 
    }
}
