//
//  BlockLinkListView.swift
//  
//
//  Created by Lennart Fischer on 24.05.22.
//

import SwiftUI

public struct BlockLinkListView: View {
    
    @EnvironmentObject var actionTransmitter: ActionTransmitter
    
    private let wrapper: PageBlock
    private let block: BlockLinkList
    
    public init(block: PageBlock) {
        self.wrapper = block
        self.block = block.data.base as! BlockLinkList
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            ForEach(block.links) { link in
                
                Button(action: {
                    
                    if let url = URL(string: link.href) {
                        actionTransmitter.dispatchOpenURL(url)
                    }
                    
                }) {
                    
                    HStack(alignment: .center, spacing: 16) {
                        
                        ZStack {
                            
                            link.icon.symbol
                                .resizable()
                                .scaledToFit()
                            
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        
                        Text(link.text)
                        
                    }
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .foregroundColor(link.color.displayForeground)
                    .background(link.color.displayBackground)
                    .cornerRadius(4)
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

extension BlockLinkList.LinkColor {
    
    public var displayBackground: Color {
        switch self {
            case .red:
                return Color.red
            case .yellow:
                return Color.yellow
            case .green:
                return Color.green
            case .black:
                return Color.black
            case .blue:
                return Color.blue
            case .orange:
                return Color.orange
            case .pink:
                return Color.pink
        }
    }
    
    public var displayForeground: Color {
        switch self {
            case .pink, .blue, .red, .black:
                return Color.white
            case .green, .yellow, .orange:
                return Color.black
        }
    }
    
}

extension BlockLinkList.LinkIcon {
    
    public var symbol: Image {
        switch self {
            case .youtube:
                return Image("youtube-play-button-fill", bundle: .module)
            case .instagram:
                return Image("instagram-fill", bundle: .module)
            case .facebook:
                return Image("facebook-circle-fill", bundle: .module)
            case .twitter:
                return Image("twitter-circle-fill", bundle: .module)
            default:
                return Image(systemName: "link")
        }
    }
    
}

struct BlockLinkListView_Previews: PreviewProvider {
    static var previews: some View {
        BlockLinkListView(block: PageBlock(
            id: 1,
            pageID: 1,
            blockType: .linkList,
            data: AnyBlockable(BlockLinkList(
                links: [
                    .init(text: "Website", href: "https://example.org", icon: .link, color: .black),
                    .init(text: "Facebook", href: "https://example.org", icon: .facebook, color: .blue),
                    .init(text: "Spotify", href: "https://example.org", icon: .spotify, color: .green),
                    .init(text: "YouTube", href: "https://example.org", icon: .youtube, color: .red),
                    .init(text: "Instagram", href: "https://example.org", icon: .instagram, color: .pink),
                    .init(text: "Twitter", href: "https://example.org", icon: .twitter, color: .blue),
                    .init(text: "Soundcloud", href: "https://example.org", icon: .soundCloud, color: .orange),
                ]
            ))
        ))
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
