//
//  TwitterFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import AppScaffold
import UIKit
//import TwitterKit

class TwitterFramework: BootstrappingProcedureStep {
    
    private let consumerKey = "K42rlEyEyNlYuAFuVfU3vyLVz"
    private let consumerSecret = "E44M4hYP1NuAM1pbK1BTjLZaBLNQ9JUICCHaxdHxiHbOd8FbHN"
    
    func execute(with application: UIApplication) {
        
//        TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
