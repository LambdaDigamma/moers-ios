//
//  TextViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

class TextViewModel {
    
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    public var paragraph: String {
        return text
    }
    
}
