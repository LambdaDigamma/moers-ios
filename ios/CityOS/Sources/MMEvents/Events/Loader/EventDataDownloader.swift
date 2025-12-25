//
//  EventDataDownloader.swift
//  
//
//  Created by Lennart Fischer on 04.05.23.
//

import Foundation
import Nuke
import MediaLibraryKit
import MMPages

public class EventDataDownloader {
    
    public let service: EventService
    public let pageService: PageService
    
    public init(service: EventService, pageService: PageService) {
        self.service = service
        self.pageService = pageService
    }
    
    public func startLoading() async throws {
        
        let events = try await service.index(cacheMode: .revalidate, withPages: true).data
        var media: [Media] = []
        
        for event in events {
            
            if let pageID = event.pageID {
                
                if let page = event.page {
                    media += page.mediaCollections.allMedia()
                } else {
                    let page = try await pageService.show(for: pageID, cacheMode: .revalidate)
                    media += page.data.mediaCollections.allMedia()
                }
                
            }
            
            media += event.mediaCollections.allMedia()
            
        }
        
    }
    
    public func downloadPictures(media: [Media]) {
        
        let prefetcher = ImagePrefetcher()
        
        let urls = media.compactMap { $0.fullURL }.compactMap { URL(string: $0) }
        
        prefetcher.startPrefetching(with: urls)
        
    }
    
}
