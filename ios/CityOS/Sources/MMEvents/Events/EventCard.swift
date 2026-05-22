//
//  EventCard.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI
import MediaLibraryKit

public struct EventCard: View {
    
//    public let data: Data
    
    @ObservedObject private var viewModel: EventListItemViewModel
    
    public init(viewModel: EventListItemViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack() {
            
            ZStack(alignment: .top) {
                if let media = viewModel.media {
                    GenericMediaView(media: media, resizingMode: .aspectFill)
                }
            }
            .background(Color.tertiarySystemBackground)
            .frame(maxWidth: .infinity)
            .aspectRatio(CGSize(width: 16, height: 10), contentMode: .fit)
            .clipped()
            .cornerRadius(16)
            
//            Rectangle()
//                .fill(Color.tertiarySystemBackground)
//                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
//                .overlay(content: {
//                    if let media = viewModel.media {
//                        GenericMediaView(media: media)
//                    }
//                })
//                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text((viewModel.location ?? "").uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Text(viewModel.title)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                EventSubtitleView(viewModel: viewModel)
                    .multilineTextAlignment(.leading)
                
//                Text(viewModel.title)
//                    .foregroundColor(.secondary)
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondarySystemBackground)
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.top, -70)
            
            
        }
        
    }
    
    public struct Data {
        
        public let title: String
        public let place: String?
        public let startDate: Date?
        public let endDate: Date?
        
    }
    
}

struct EventCard_Previews: PreviewProvider {
    static var previews: some View {
        EventCard(viewModel: .init(
            eventID: 1,
            title: "Ghost Dogs (DE)",
            startDate: Date(),
            endDate: Date().addingTimeInterval(60 * 30),
            location: "Bettenkamper Meer",
            scheduleDisplayMode: .dateTime
        ))
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
