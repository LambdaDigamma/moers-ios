//
//  NewsItemPanel.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import SwiftUI
import Core
import NukeUI

public struct NewsItemPanel: View {

    @Environment(\.colorScheme) var colorScheme
    
    private let headline: String
    private let source: String
    private let publishedAt: Date
    private let imageURL: String?

    public init(
        headline: String,
        source: String,
        publishedAt: Date,
        imageURL: String? = nil
    ) {
        self.headline = headline
        self.source = source
        self.publishedAt = publishedAt
        self.imageURL = imageURL
    }

    public var body: some View {

        CardPanelView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                if let imageURL = imageURL, let url = URL(string: imageURL) {
                    LazyImage(url: url) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if state.error != nil {
                            Color(UIColor.secondarySystemFill)
                                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                        } else {
                            Color(UIColor.secondarySystemFill)
                                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        textOverlay()
                    }
//                    .frame(maxWidth: .infinity, minHeight: 250, idealHeight: 250, maxHeight: 250)
                    
                }
                
            }
            
        }
        .cardPanelBorder(CardPanelBorder(color: colorScheme == .dark ? Color.white.opacity(0.2) : .clear, lineWidth: 1))
        
    }
    
    @ViewBuilder
    private func textOverlay() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(headline)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Group {
                Text(publishedAt, formatter: Self.formatter) +
                Text(" · ") +
                Text(source)
            }
            .font(.footnote)
            
        }
        .foregroundColor(Color.white)
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 40)
        .background(LinearGradient(colors: [.clear, .black.opacity(0.7), .black], startPoint: .top, endPoint: .bottom))
//        .background(Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground))
        
    }
    
    public static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

}

struct NewsItemPanel_Previews: PreviewProvider {
    static var previews: some View {
        NewsItemPanel(
            headline: "Einkaufen in Moers: Läden sollen am Kirmessonntag öffnen",
            source: "RP Online",
            publishedAt: Date()
        )
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
