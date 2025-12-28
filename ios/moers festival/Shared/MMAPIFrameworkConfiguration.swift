//
//  MMAPIFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import AVFoundation
import ModernNetworking
import Core

class MMAPIFrameworkConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        var components = URLComponents()
        
        components.scheme = NetworkingConfiguration.environment.scheme
        components.host = NetworkingConfiguration.environment.host
        
        if let url = components.url {
            ApplicationServerConfiguration.registerBaseURL(url.absoluteString)
            ApplicationServerConfiguration.isMoersFestivalModeEnabled = true
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print(error.localizedDescription)
        }
        
        let memoryCapacity = 4 * 1024 * 1024 // 4 megabyte memory cache
        let diskCapacity = 20 * 1024 * 1024 // 20 megabyte disk cache
        
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
        
        URLCache.shared = cache
        
        #if !os(tvOS)
        AnalyticsManager.shared.incrementAppRuns()
        
        print("App Runs: \(AnalyticsManager.shared.getAppRuns())")
        #endif
        
    }
    
}
