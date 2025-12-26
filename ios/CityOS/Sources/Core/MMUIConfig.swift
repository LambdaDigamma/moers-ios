//
//  MMUIConfig.swift
//  MMUI
//
//  Created by Lennart Fischer on 15.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import UIKit

public typealias MarkdownConverter = ((String) -> NSAttributedString)

public struct MMUIConfig {
    
    /// The shared theme using native iOS colors
    public static var theme: ApplicationTheme = ApplicationTheme()
    
    public static var markdownConverter: MarkdownConverter = { text in
        
        return text.htmlToAttributedString ?? NSAttributedString()
        
    }
    
}
