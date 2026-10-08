//
//  NativePageContentRenderer.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import SwiftUI

/// Renders a lazy stack of all page blocks provided.
public struct NativePageContentRenderer: View {
    
    private let blocks: [PageBlock]
    private let frame: CGSize
    
    public init(blocks: [PageBlock], frame: CGSize) {
        self.blocks = blocks
        self.frame = frame
    }
    
    public var body: some View {
        
        LazyVStack(spacing: 0) {
            
            ForEach(blocks) { block in
                PageBlockView(pageBlock: block, containerFrame: frame)
            }
            
        }
        
    }
    
}

struct NativePageContentRenderer_Previews: PreviewProvider {
    static var previews: some View {
        NativePageContentRenderer(blocks: [], frame: .init(width: 400, height: 600))
    }
}
