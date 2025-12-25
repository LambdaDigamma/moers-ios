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

        ZStack {
            
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if state.error != nil {
                        Color(UIColor.secondarySystemFill)
                    } else {
                        Color(UIColor.secondarySystemFill)
                    }
                }
                    
            }
            
        }
        .frame(maxWidth: .infinity, minHeight: 250, idealHeight: 250, maxHeight: 250)
        .overlay(textOverlay())
        .cornerRadius(18)
        
    }
    
    @ViewBuilder
    private func textOverlay() -> some View {
        
        ZStack(alignment: .bottom) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(headline)
                    .font(.footnote)
                    .fontWeight(.semibold)
                
                Group {
                    Text(publishedAt, formatter: Self.formatter) +
                    Text(" • ") +
                    Text(source)
                }
                .font(.caption)
                
            }
            .foregroundColor(Color(UIColor.label))
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            
        }.frame(maxHeight: .infinity, alignment: .bottomLeading)
        
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
