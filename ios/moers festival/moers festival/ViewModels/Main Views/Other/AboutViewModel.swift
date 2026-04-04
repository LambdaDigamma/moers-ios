//
//  AboutViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

class AboutViewModel {
    
    public var cfnTitle: String {
        return "Code for Niederrhein"
    }
    
    public var cfnText: String {
        return "Twitter: twitter.com/codefornrn\nWebsite: codeforniederrhein.de"
    }
    
    public var name: String {
        return "Lennart Fischer"
    }
    
    public var meText: String {
        return "Twitter: twitter.com/lambdadigamma"
    }
    
    public var infoText: String {
        return String(localized: "This app is a project by the Code for Niederrhein group and was developed by Lennart Fischer.\n\n\nAll data is provided without guarantee.")
    }
    
}
