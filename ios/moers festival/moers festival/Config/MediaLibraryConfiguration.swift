//
//  MediaLibraryConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import MediaLibraryKit
import Nuke
import NukeWebP
import NukeWebPBasic

class MediaLibraryConfiguration: BootstrappingProcedureStep {
    
    let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func execute(with application: UIApplication) {
        
        WebPImageDecoder.enable(auto: BasicWebPDecoder())
        
        let diskCapacity = Int(Measurement(
            value: 256,
            unit: UnitInformationStorage.megabytes
        ).converted(to: .bytes).value)
        
        let memoryCapacity = Int(Measurement(
            value: 20,
            unit: UnitInformationStorage.megabytes
        ).converted(to: .bytes).value)
         
        DataLoader.sharedUrlCache.diskCapacity = diskCapacity
        DataLoader.sharedUrlCache.memoryCapacity = memoryCapacity
        
        let pipeline = ImagePipeline {
            
            let dataCache = try? DataCache(name: "de.okfn.niederrhein.moers-festival.datacache")
            dataCache?.sizeLimit = diskCapacity
            $0.dataCache = dataCache
            
        }
        
        ImagePipeline.shared = pipeline
        
    }
    
}

