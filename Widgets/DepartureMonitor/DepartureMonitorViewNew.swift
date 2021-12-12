//
//  DepartureMonitorViewNew.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 08.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import WidgetKit
import SwiftUI
import EFAAPI

struct DepartureMonitorViewNew: View {
    
    var entry: DepartureMonitorEntry
    
    @Environment(\.colorScheme) var colorScheme
    
    static let taskDateFormat: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.formattingContext = .standalone
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .numeric
        return formatter
    }()
    
    var cardBackgroundColor: Color {
        if colorScheme == .light {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        
        ZStack {
            
            cardBackgroundColor
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Duisburg Hbf")
                    .font(.headline)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    let departures = entry.departures.prefix(3)
                    
                    ForEach(departures) { departure in
                        
                        HStack {
                            
//                            Text("\(departure.actual ?? departure.time ?? Date(), formatter: timeFormatter)")
//                                .font(.system(.caption2, design: Font.Design.monospaced))
//                                .fontWeight(.semibold)
//                                .padding(4)
//                                .padding(.horizontal, 4)
//                                .background(Color(UIColor.secondarySystemBackground))
//                                .foregroundColor(timeForegroundColor(for: departure))
//                                .cornerRadius(6)
                            
                            chip(Text("\(departure.actual ?? departure.time ?? Date(), formatter: timeFormatter)"))
                                .foregroundColor(timeForegroundColor(for: departure))
                            
                            Text(departure.direction)
                                .font(.system(.caption2))
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                
                                chip(Text(String(departure.symbol.prefix(7))))
                                    .foregroundColor(Color(UIColor.label))
                                
                                chip(Text(departure.sanitizedPlatform))
                                    .foregroundColor(Color(UIColor.label))
                                
                            }
                            
                        }
                    }
                    
                }
                
                Spacer()
                
                HStack {

//                    Text("nur ICE 22 & RE 5")
//                        .layoutPriority(100)
//                    Spacer()
//                        .frame(maxWidth: .infinity)
//                        .layoutPriority(50)
                    
                    HStack {
                        Text("zuletzt aktualisiert: ") +
                        Text(entry.date, style: .relative)
                    }
                    .layoutPriority(100)
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(.secondary)
                .font(.system(size: 8, weight: .regular, design: .default))
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
        }
        
    }
    
    @ViewBuilder
    private func chip(_ text: Text) -> some View {
        
        text
            .font(.system(.caption2, design: Font.Design.monospaced))
            .fontWeight(.semibold)
            .padding(4)
            .padding(.horizontal, 2)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(6)
        
    }
    
    func timeForegroundColor(for departure: DepartureViewModel) -> Color {
        if departure.actual != nil {
            return Color.green
        } else {
            return Color(UIColor.label)
        }
    }
    
}

struct DepartureMonitorViewNew_Previews: PreviewProvider {
    static var previews: some View {
        
        let entry = DepartureMonitorEntry(
            date: Date(timeIntervalSinceNow: -60 * 8),
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
        
        DepartureMonitorViewNew(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.locale, Locale(identifier: "de"))
        
        DepartureMonitorViewNew(entry: entry)
            .environment(\.locale, Locale(identifier: "de"))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
