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
    private let timeDisplayMode: TimeDisplayMode
    private let location: String?
    private let artists: [String]
    private let isOpenEnd: Bool
    
    public init(
        title: String,
        startDate: Date?,
        endDate: Date?,
        timeDisplayMode: TimeDisplayMode,
        location: String? = nil,
        artists: [String] = [],
        isOpenEnd: Bool = false
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.timeDisplayMode = timeDisplayMode
        self.location = location
        self.artists = artists
        self.isOpenEnd = isOpenEnd
    }
    
    private var duration: String {
        
        if isOpenEnd {
            return ""
        }
        
        if let dateRange = EventUtilities.dateRange(startDate: startDate, endDate: endDate),
           let duration = Self.durationFormatter.string(from: dateRange.lowerBound, to: dateRange.upperBound) {
            return "(Dauer: \(duration))"
        }
        
        return ""
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Label {
                Text(location ?? EventPackageStrings.locationNotKnown) + Text(" \(Image(systemName: "chevron.right"))")
            } icon: {
                Image(systemName: "mappin.circle")
                    .frame(minWidth: 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Label {
                
                HStack {
                    
                    if timeDisplayMode == .none {
                        Text(EventPackageStrings.notYetScheduled)
                    } else if let startDate, isOpenEnd {
                        Text(startDate, style: .time)
                    } else if let dateRange = EventUtilities.dateRange(startDate: startDate, endDate: endDate) {
                        Text(dateRange)
                    } else {
                        Text(EventPackageStrings.notYetScheduled)
                    }
                    
                    Spacer()
                    
                }
                
            } icon: {
                Image(systemName: "calendar.circle")
                    .frame(minWidth: 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Label {
                
                if !artists.isEmpty {
                    Text(ListFormatter.localizedString(byJoining: artists))
                        .lineLimit(2)
                }
                
            } icon: {
                Image(systemName: "person.2.circle")
                    .frame(minWidth: 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            
//            switch timeDisplayMode {
//
//                case .live:
//
//                    LiveBadge()
//
//                case .relative:
//
//                    VStack(alignment: .leading) {
//
//                        if let startDate = startDate {
//
//                            if #available(iOS 15.0, *) {
//
//                                Text(startDate, format: .relative(presentation: .numeric)) +
//                                Text(" ") +
//                                Text(duration)
//
//                            }
//
//                        }
//
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                case .range:
//                    if let dateRange = EventUtilities.dateRange(startDate: startDate, endDate: endDate) {
//                        Text(dateRange)
//                    }
//
//                case .none:
//                    Text("Keine Zeit")
//
//            }
            
        }
        .foregroundColor(.secondary)
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .padding()
        
    }
    
    internal static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour]
        formatter.formattingContext = .standalone
        formatter.unitsStyle = .full
        return formatter
    }()
    
}

struct EventDetailInformationRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        EventDetailInformationRow(
            title: "SEABROOK TRIO (US)",
            startDate: Date(timeIntervalSinceNow: 60 * 5),
            endDate: Date(timeIntervalSinceNow: 60 * 45),
            timeDisplayMode: .relative,
            location: nil,
            artists: ["Anna Webber (sax)","Max Johnson (bass)","Michael Sarin (drums)"]
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        
        EventDetailInformationRow(
            title: "SEABROOK TRIO (US)",
            startDate: Date(timeIntervalSinceNow: 60 * 5),
            endDate: Date(timeIntervalSinceNow: 60 * 45),
            timeDisplayMode: .live,
            location: nil,
            artists: ["Anna Webber (sax)","Max Johnson (bass)","Michael Sarin (drums)"]
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Live")
        
    }
    
}
