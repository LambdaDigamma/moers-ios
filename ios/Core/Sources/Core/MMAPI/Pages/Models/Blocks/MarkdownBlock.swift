//
//  MarkdownBlock.swift
//  
//
//  Created by Lennart Fischer on 05.02.20.
//

import Foundation

final public class MarkdownBlock: NSObject, Blockable {
    
    public static var type: BlockType = .markdown
    
    public init(text: String) {
        self.text = text
    }
    
    public var text: String
    
    public var attributedText: NSAttributedString {
        
        // todo: markdown
        
        if #available(iOS 15, *) {
            return (try? NSAttributedString(markdown: text)) ?? NSAttributedString(string: text)
        } else {
            return NSAttributedString(string: text)
        }
        
//        let parser = MarkdownParser()
//        let html = parser.html(from: text)
//
//        return html.htmlToAttributedString ?? NSAttributedString()
        
    }
    
    
}
