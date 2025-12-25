//
//  TextBlockView.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import SwiftUI
import ProseMirror

struct TextBlockView: View {
    
    private let wrapper: PageBlock
    private let block: TextBlock
    private let frame: CGSize
    
    public init(block: PageBlock, frame: CGSize) {
        self.wrapper = block
        self.block = block.data.base as! TextBlock
        self.frame = frame
    }
    
    var body: some View {
        TextBlockRenderer(document: block.text ?? Document())
            .proseDefaultColor(.secondary)
            .padding()
    }
}

struct TextBlockRenderer: View {
    
    var document: Document
    
    var body: some View {
        
        document
            .proseDefaultColor(.secondary)
        
    }
    
}

public struct DetailText: View {
    
    public var document: Document
    
    public var body: some View {
        
        document
            .proseDefaultColor(.secondary)
        
    }
    
}

public struct BlockTextWithMediaView: View {
    
    private let wrapper: PageBlock
    private let block: TextBlock
    
    public init(block: PageBlock) {
        self.wrapper = block
        self.block = block.data.base as! TextBlock
    }
    
    public var body: some View {
        
        VStack(spacing: 8) {
            
            if let title = block.title {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let subtitle = block.subtitle {
                Text(subtitle)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            DetailText(document: block.text ?? Document())
                .proseDefaultColor(.secondary)
                .foregroundColor(.white)
//                .proseUnorderedListItemStyle(style: BulletStyle##BulletStyle)
            
            ForEach(wrapper.children) { childBlock in
                PageBlockView(pageBlock: childBlock, containerFrame: .zero)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        
    }
    
}
