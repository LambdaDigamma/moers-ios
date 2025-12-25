//
//  OpeningHoursContainer.swift
//  
//
//  Created by Lennart Fischer on 16.01.22.
//

import SwiftUI

public struct OpeningHoursContainer: View {
    
    private let openingHours: [OpeningHourEntry]
    
    public init(openingHours: [OpeningHourEntry]) {
        self.openingHours = openingHours
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text("Öffnungszeiten")
                .fontWeight(.semibold)
                .padding(.bottom, 8)
                .unredacted()
            
            if !openingHours.isEmpty {
                ForEach(openingHours) { entry in
                    HStack(alignment: .top) {
                        Text(entry.text)
                        Spacer()
                        Text(entry.time)
                    }
                }
            } else {
                Text("Keine Öffnungszeiten bekannt")
                    .foregroundColor(.secondary)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

struct OpeningHoursContainer_Previews: PreviewProvider {
    static var previews: some View {
        
        OpeningHoursContainer(openingHours: [
            .init(text: "Mo-Fr", time: "09:00 - 19:00"),
            .init(text: "Sa", time: "09:00 - 16:00"),
            .init(text: "So", time: "10:00 - 14:00"),
        ])
            .padding()
            .previewLayout(.sizeThatFits)
        
        OpeningHoursContainer(openingHours: [
            .init(text: "Mo-Fr", time: "09:00 - 19:00"),
            .init(text: "Sa", time: "09:00 - 16:00"),
            .init(text: "So", time: "10:00 - 14:00"),
        ])
            .padding()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark")
        
        OpeningHoursContainer(openingHours: [])
            .padding()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("No entries")
        
        OpeningHoursContainer(openingHours: [
            .init(text: "Mo-Fr", time: "09:00 - 19:00"),
            .init(text: "Sa", time: "09:00 - 16:00"),
        ])
            .padding()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .redacted(reason: .placeholder)
            .previewDisplayName("Loading placeholder")
        
    }
}
