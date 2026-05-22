//
//  EventDetailInformationRow.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import SwiftUI
import MMEvents

public struct EventDetailInformationRow: View {
    
    private let title: String
    private let startDate: Date?
    private let endDate: Date?
    private let scheduleDisplayMode: EventScheduleDisplayMode
    private let location: String?
    private let artists: [String]
    private let isOpenEnd: Bool
    
    public init(
        title: String,
        startDate: Date?,
        endDate: Date?,
        scheduleDisplayMode: EventScheduleDisplayMode,
        location: String? = nil,
        artists: [String] = [],
        isOpenEnd: Bool = false
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.scheduleDisplayMode = scheduleDisplayMode
        self.location = location
        self.artists = artists
        self.isOpenEnd = isOpenEnd
    }

    private var sanitizedArtists: [String] {
        artists.filter { !$0.isEmptyOrWhitespace }
    }

    public var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityIdentifier("EventDetail.Title")
            
            Label {
                Text(location ?? EventPackageStrings.locationNotKnown) + Text(" \(Image(systemName: "chevron.right"))")
            } icon: {
                Image(systemName: "mappin.circle")
                    .frame(minWidth: 20)
            }
            .accessibilityIdentifier("EventDetail.Location")
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if scheduleDisplayMode.showsDateComponent {
                Label {
                    HStack {
                        EventSubtitleView(
                            startDate: startDate,
                            endDate: endDate,
                            scheduleDisplayMode: scheduleDisplayMode,
                            location: nil,
                            isOpenEnd: isOpenEnd
                        )

                        Spacer()
                    }
                } icon: {
                    Image(systemName: "calendar.circle")
                        .frame(minWidth: 20)
                }
                .accessibilityIdentifier("EventDetail.DateTime")
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Label {
                
                if sanitizedArtists.isEmpty {
                    Text("To be announced")
                        .foregroundColor(.secondary)
                } else {
                    Text(ListFormatter.localizedString(byJoining: sanitizedArtists))
                        .lineLimit(2)
                }
                
            } icon: {
                Image(systemName: "person.2.circle")
                    .frame(minWidth: 20)
            }
            .accessibilityIdentifier("EventDetail.Artists")
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .foregroundColor(.secondary)
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .padding()
        
    }

}

struct EventDetailInformationRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        EventDetailInformationRow(
            title: "SEABROOK TRIO (US)",
            startDate: Date(timeIntervalSinceNow: -60 * 5),
            endDate: Date(timeIntervalSinceNow: 60 * 45),
            scheduleDisplayMode: .dateTime,
            location: nil,
            artists: ["Anna Webber (sax)","Max Johnson (bass)","Michael Sarin (drums)"]
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        
        EventDetailInformationRow(
            title: "SEABROOK TRIO (US)",
            startDate: Date(timeIntervalSinceNow: 60 * 5),
            endDate: Date(timeIntervalSinceNow: 60 * 45),
            scheduleDisplayMode: .dateTime,
            location: nil,
            artists: ["Anna Webber (sax)","Max Johnson (bass)","Michael Sarin (drums)"]
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Live")
        
    }
    
}
