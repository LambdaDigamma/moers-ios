//
//  DepartureMonitorView.swift
//  
//
//  Created by Lennart Fischer on 08.12.21.
//

import SwiftUI
import EFAAPI

#if canImport(WidgetKit)
import WidgetKit
#endif

#if canImport(UIKit)

public struct DepartureMonitorView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    public var viewModel: DepartureMonitorViewModel
    
    private var showBackground: Bool
    
    public init(viewModel: DepartureMonitorViewModel, showBackground: Bool = true) {
        self.viewModel = viewModel
        self.showBackground = showBackground
    }
    
    private var cardBackgroundColor: Color {
        if colorScheme == .light {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.stationName)
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 4) {
                
                let departures = viewModel.departures.prefix(3)
                
                ForEach(departures) { departure in
                    
                    DepartureRowView(departure: departure)
                    
                }
                
            }
            
            Spacer()
                .frame(maxHeight: 20)
            
            HStack {
                
                HStack {
                    Text("zuletzt aktualisiert: ") +
                    Text(viewModel.date, style: .relative)
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
        .background(ZStack(alignment: .bottomTrailing) {
            
            if showBackground {
                
                Image("station-background", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100)
                    .unredacted()
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing))
        .background(showBackground ? cardBackgroundColor : .clear)
        
    }
    
}

struct DepartureMonitorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewModel = DepartureMonitorViewModel(
            stationName: "Duisburg Hbf",
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
            ],
            date: Date(timeIntervalSinceNow: -60 * 8)
        )
        
        DepartureMonitorView(viewModel: viewModel)
            .environment(\.locale, Locale(identifier: "de"))
            .previewLayout(.sizeThatFits)
        
        DepartureMonitorView(viewModel: viewModel)
            .environment(\.locale, Locale(identifier: "de"))
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
        
        DepartureMonitorView(viewModel: viewModel)
            .environment(\.locale, Locale(identifier: "de"))
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
            .redacted(reason: .placeholder)
        
    }
    
}

#endif
