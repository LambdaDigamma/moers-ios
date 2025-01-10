//
//  BroadcastRow.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI
import Nuke
import NukeUI

public struct BroadcastRow: View {
    
    private let title: String
    private let subtitle: String
    private let imageURL: URL?
    
    public init(
        viewModel: RadioBroadcastViewModel
    ) {
        self.title = viewModel.title
        self.subtitle = viewModel.subtitle
        self.imageURL = URL(string: viewModel.imageURL ?? "")
    }
    
    public init(
        title: String,
        subtitle: String,
        imageURL: String?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = URL(string: imageURL ?? "")
    }
    
    public var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            ZStack {
                
                if let imageURL = imageURL {
                    LazyImage(url: imageURL)
                        .processors([ImageProcessors.Resize(width: 44)])
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.tertiarySystemFill))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 44, maxHeight: 44)
                }
                
            }
            .frame(maxWidth: 44, maxHeight: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(title)
                    .foregroundColor(.primary)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Image(systemName: "chevron.forward")
                .font(.body.weight(.semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .padding(.vertical)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

public struct BroadcastRow_Preview: PreviewProvider {
    
    public static var previews: some View {
        BroadcastRow(
            title: "Landeskirchschicht in Kamp-Lintfort",
            subtitle: "9/10/21, 6:04 – 7:24 PM",
            imageURL: nil
        )
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
    
}
