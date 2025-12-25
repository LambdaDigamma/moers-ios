//
//  ImageCollectionView.swift
//
//
//  Created by Lennart Fischer on 11.05.24.
//

import SwiftUI
import MediaLibraryKit

struct ImageCollectionView: View {
    
    private let wrapper: PageBlock
    private let block: BlockImageCollection
    
    public init(block: PageBlock) {
        self.wrapper = block
        self.block = block.data.base as! BlockImageCollection
    }
    
    public var body: some View {
        
        if let image = wrapper.mediaCollectionsContainer?.getFirstMedia(for: "images") {
            
            GenericMediaView(media: image, resizingMode: .aspectFill)
                .aspectRatio(
                    CGSize(
                        width: image.responsiveWidth ?? 16,
                        height: image.responsiveHeight ?? 9
                    ),
                    contentMode: .fill
                )
            
            
        }
        
    }
    
}
