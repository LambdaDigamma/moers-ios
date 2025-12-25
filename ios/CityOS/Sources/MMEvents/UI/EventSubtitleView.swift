//
//  EventSubtitleView.swift
//  
//
//  Created by Lennart Fischer on 20.05.22.
//

import Foundation
import SwiftUI


public struct EventSubtitleView: View {
    
    private let startDate: Date?
    private let endDate: Date?
    private let timeDisplayMode: TimeDisplayMode
    private let location: String?
    
    public init(
        startDate: Date?,
        endDate: Date?,
        timeDisplayMode: TimeDisplayMode,
        location: String? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.timeDisplayMode = timeDisplayMode
        self.location = location
    }
    
    public var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            switch timeDisplayMode {
                    
                case .live:
                    
                    (location != nil ? Text("\(location ?? "")") : Text(""))
//                        .padding(.leading, 8)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    LiveBadge()
                    
                case .relative:
                    if let startDate = startDate {
                        
                        Group {
                            
                            if #available(iOS 15.0, *) {
                                Text(startDate, format: .relative(presentation: .numeric)) +
                                (location != nil ?
                                 Text(" • \(location ?? "")") :
                                    Text(""))
                            }
                            
                        }.lineLimit(1)
                        
                    }
                    
                case .range:
                    
                    if let dateRange = EventUtilities.dateRange(startDate: startDate, endDate: endDate) {
                        
                        Group {
                            
                            Text(dateRange) +
                            (location != nil ? Text(" • \(location ?? "")") : Text(""))
                            
                        }
                        .lineLimit(1)
                        
                    }
                    
                case .none:
                    Text("Keine Zeit")
                    
            }
            
        }
        .foregroundColor(.secondary)
        .font(.callout)
        
    }
    
}
