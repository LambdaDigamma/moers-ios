//
//  DepartureRow.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 08.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import EFAAPI
import WidgetKit

public struct DepartureRow: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let departure: DepartureViewModel
    
    public init(departure: DepartureViewModel) {
        self.departure = departure
    }
    
    public var body: some View {
        
        HStack {
            
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

struct DepartureRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let departure = DepartureViewModel(
            departure: ITDDeparture.stub()
                .setting(\.actualDateTime,
                          to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 2)))
                .setting(\.servingLine.direction, to: "Münster (Westf) Hbf")
                .setting(\.servingLine.symbol, to: "S1")
        )
        
        ZStack {
            
            Color.black
            
            DepartureRow(departure: departure)
                .padding()
                .environment(\.colorScheme, .dark)
            
        }
        .environment(\.sizeCategory, .extraSmall)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .preferredColorScheme(.dark)
        
        ZStack {
            
            Color.black
            
            DepartureRow(departure: departure)
                .padding()
                .environment(\.colorScheme, .dark)
            
        }
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .preferredColorScheme(.dark)
        
        ZStack {
            
            Color.black
            
            DepartureRow(departure: departure)
                .padding()
                .environment(\.colorScheme, .dark)
            
        }
        .environment(\.sizeCategory, .extraExtraExtraLarge)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .preferredColorScheme(.dark)
        
    }
    
}
