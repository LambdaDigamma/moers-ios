//
//  BlockImageCollectionView.swift
//  
//
//  Created by Lennart Fischer on 25.05.22.
//

import SwiftUI
import MediaLibraryKit

public struct BlockImageCollectionView: View {
    
    private let wrapper: PageBlock
    private let block: BlockImageCollection
    
    public init(block: PageBlock) {
        self.wrapper = block
        self.block = block.data.base as! BlockImageCollection
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            if let images = wrapper.mediaCollectionsContainer?.collections["images"] {
                
                ForEach(images) { (image: Media) in
                    
                    if let width = image.responsiveWidth,
                       let height = image.responsiveHeight {
                        
                        GenericMediaView(media: image, resizingMode: .aspectFit)
                            .aspectRatio(CGSize(width: width, height: height), contentMode: .fit)
                    
                    }
                    
                }
                
            }
            
            if let text = block.text {
                
                text
                    .proseDefaultColor(.secondary)
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

//struct BlockImageCollection_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockImageCollection()
//    }
//}
