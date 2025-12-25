//
//  DepartureRowView.swift
//  
//
//  Created by Lennart Fischer on 08.12.21.
//

import SwiftUI
import EFAAPI

#if canImport(UIKit)
import UIKit

public struct DepartureRowView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let departure: DepartureViewModel
    
    public init(departure: DepartureViewModel) {
        self.departure = departure
    }
    
    public var body: some View {
        
        HStack {
            
            chip(Text("\(departure.actual ?? departure.time ?? Date(), formatter: Self.timeFormatter)"))
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
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(6)
        
    }
    
    private func timeForegroundColor(for departure: DepartureViewModel) -> Color {
        if departure.actual != nil {
            return Color.green
        } else {
            return Color(UIColor.label)
        }
    }
    
    public static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
}

struct DepartureRowView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let departure = DepartureViewModel(
            departure: ITDDeparture.stub()
                .setting(\.actualDateTime,
                          to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 2)))
                .setting(\.servingLine.direction, to: "Münster (Westf) Hbf")
                .setting(\.servingLine.symbol, to: "S1")
        )
        
        DepartureRowView(departure: departure)
            .padding()
            .previewLayout(.sizeThatFits)
        
        DepartureRowView(departure: departure)
            .padding()
            .environment(\.colorScheme, .dark)
            .environment(\.sizeCategory, .extraSmall)
            .environment(\.locale, Locale(identifier: "de"))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
        
        DepartureRowView(departure: departure)
            .padding()
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
        DepartureRowView(departure: departure)
            .padding()
            .environment(\.colorScheme, .dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
        
    }
    
}

#endif
