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
        let twitterURL = "twitter.com/codefornrn"
        let websiteURL = "codeforniederrhein.de"
        return String(localized: "Twitter: \(twitterURL)\nWebsite: \(websiteURL)", comment: "About contact details. The placeholders are the Twitter and website addresses.")
    }
    
    public var name: String {
        return "Lennart Fischer"
    }
    
    public var meText: String {
        let twitterURL = "twitter.com/lambdadigamma"
        return String(localized: "Twitter: \(twitterURL)", comment: "Developer contact. The placeholder is a Twitter address.")
    }
    
    public var infoText: String {
        return String(localized: "This app is a project by the Code for Niederrhein group and was developed by Lennart Fischer.\n\n\nAll data is provided without guarantee.")
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
