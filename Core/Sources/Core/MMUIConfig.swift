//
//  MMUIConfig.swift
//  MMUI
//
//  Created by Lennart Fischer on 15.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import Gestalt
import UIKit

public typealias MarkdownConverter = ((String) -> NSAttributedString)

public struct MMUIConfig {
    
    public static var themeManager: ThemeManager?
    
    public static var markdownConverter: MarkdownConverter = { text in
        
        return text.htmlToAttributedString ?? NSAttributedString()
        
//        let parser = MarkdownParser()
//        let html = parser.html(from: text)
//
//
//
//        let styledText = html.htmlToAttributedString ?? NSAttributedString()
//        let mutable = NSMutableAttributedString(attributedString: styledText)
//        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 4
//
//        mutable.addAttributes([
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
//            NSAttributedString.Key.foregroundColor : UIColor.white,
//            NSAttributedString.Key.paragraphStyle : style
//        ], range: NSRange(location: 0, length: styledText.length))
//
//        return mutable
        
    }
    
    public static func registerThemeManager(_ manager: ThemeManager) {
        self.themeManager = manager
    }
    
}
