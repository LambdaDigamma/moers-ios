//
//  DepartureMonitorView.swift
//  Moers
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import WidgetKit
import SwiftUI
import EFAAPI
import EFAUI

struct DepartureMonitorView: View {
    
    var entry: DepartureMonitorEntry
    
    static let taskDateFormat: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.formattingContext = .standalone
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .numeric
        return formatter
    }()
    
    var body: some View {
        
        Text("ABC")
        
//        EFAUI.DepartureMonitorView
        
//        ZStack {
//
//            Color(UIColor.systemBackground)
//
//            VStack(alignment: .leading) {
//
//                VStack(alignment: .leading, spacing: 4) {
//
//                    let departures = entry.departures.prefix(4)
//
//                    ForEach(departures) { departure in
//
//                        HStack {
//
//                            Text("\(departure.actual ?? departure.time ?? Date(), formatter: timeFormatter)")
//                                .font(.system(.caption2, design: Font.Design.monospaced))
//                                .fontWeight(.semibold)
//                                .padding(4)
//                                .padding(.horizontal, 4)
//                                .background(Color(UIColor.secondarySystemBackground))
//                                .foregroundColor(timeForegroundColor(for: departure))
//                                .cornerRadius(6)
//
//                            Text(departure.direction)
//                                .font(.system(.caption2))
//
//                            Spacer()
//
//                            Text(String(departure.symbol.prefix(7)))
//                                .font(.system(.caption2, design: Font.Design.monospaced))
//                                .fontWeight(.semibold)
//                                .padding(4)
//                                .padding(.horizontal, 4)
//                                .background(Color.blue)
//                                .foregroundColor(Color(UIColor.label))
//                                .cornerRadius(6)
//
//                        }
//                    }
//
//                }
//
//                Spacer()
//
//                HStack {
//
//                    Group {
//                        Text(entry.name) +
//                        Text(" • ") +
//                        Text("Last update: ") +
//                        Text(entry.date, style: .relative)
//                    }
//                    .foregroundColor(.secondary)
//                    .font(.system(size: 8, weight: .regular, design: .default))
//
//                }
//
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 16)
//            .padding(.vertical, 16)
//
//        }
        
    }
    
    func timeForegroundColor(for departure: DepartureViewModel) -> Color {
        if departure.actual != nil {
            return Color.green
        } else {
            return Color(UIColor.label)
        }
    }
    
}

var timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

struct DepartureMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        
        let entry = DepartureMonitorEntry(
            date: Date(timeIntervalSinceNow: -60 * 8),
            departures: [
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.actualDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 2)))
                        .setting(\.servingLine,
                                  to: ITDServingLine.stub().setting(\.symbol, to: "ICE 972"))
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 5)))
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 10)))
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 20)))
                )
            ])
        
        DepartureMonitorView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.locale, Locale(identifier: "de"))
        
        DepartureMonitorView(entry: entry)
            .environment(\.locale, Locale(identifier: "de"))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
