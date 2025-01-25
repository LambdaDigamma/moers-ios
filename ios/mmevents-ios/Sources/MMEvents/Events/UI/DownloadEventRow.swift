//
//  DownloadEventRow.swift
//  
//
//  Created by Lennart Fischer on 04.05.23.
//

import SwiftUI
import Core
import Factory
import Combine
import MMPages
import Nuke
import MediaLibraryKit

class DownloadEventViewModel: StandardViewModel {
    
    private let repository: EventRepository
    private let pageRepository: PageRepository
    
    private let imagePrefetcher = ImagePrefetcher()
    
    public let eventID: Event.ID
    
    @Published var event: EventRecord
    @Published var page: PageRecord?
    
    @Published var content: Core.DataState<Bool, Error> = .success(false)
    @Published var media: Core.DataState<Bool, Error> = .success(false)
    
    public init(eventID: Event.ID, event: EventRecord) {
        self.eventID = eventID
        self.event = event
        self.repository = Container.shared.eventRepository()
        self.pageRepository = Container.shared.pageRepository()
        
        super.init()
        self.setupListener()
    }
    
    public func setupListener() {
        
        guard let pageID = event.pageID.toInt() else {
            self.content = .success(true)
            return
        }
        
        pageRepository.store
            .pageObserver(pageID: pageID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
                if let error = completion.error {
                    self.content = .error(error)
                }
                
            } receiveValue: { (page: PageRecord?) in
                
                if let page {
                    self.page = page
                    self.content = .success(true)
                } else {
                    self.content = .success(false)
                }
                
                self.checkImagesExistInCache()
                
            }
            .store(in: &cancellables)
        
    }
    
    public func checkImagesExistInCache() {
        
        let notLoadedMedia = collectMediaFilteringNotLoaded()
        
        DispatchQueue.main.async {
            if !notLoadedMedia.isEmpty {
                self.media = .success(false)
            } else {
                self.media = .success(true)
            }
        }
        
    }
    
    public func download(loadingConfiguration: LoadingConfiguration) {
        
//        if loadingConfiguration.downloadContent {
//            downloadContent()
//        }
        
        if loadingConfiguration.downloadMedia {
            downloadMedia()
        }
        
    }
    
    public func downloadContent() {
        
        Task {
            
            do {
                
                if let value = content.value, let pageID = event.pageID.toInt(), value == false {
                    DispatchQueue.main.async {
                        self.content = .loading
                    }
                    try await pageRepository.reloadPage(for: pageID)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.content = .error(error)
                }
                
                print(error)
                
            }
            
        }
        
    }
    
    public func setContentState(_ state: Core.DataState<Bool, Error>) {
        
        DispatchQueue.main.async {
            self.content = state
        }
        
    }
    
    public func downloadMedia() {
        
        Task {
            
            if let media = self.media.value, media == false {
                
                let notLoadedMedia = collectMediaFilteringNotLoaded()
                let urls = notLoadedMedia.compactMap { $0.fullURL }.compactMap { URL(string: $0) }
                
                guard !urls.isEmpty else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.media = .loading
                }
                
                imagePrefetcher.priority = .veryHigh
                imagePrefetcher.didComplete = {
                    self.checkImagesExistInCache()
                }
                imagePrefetcher.startPrefetching(with: urls)
                
                
            }
            
        }
        
    }
    
    private func collectMedia() -> [Media] {
        
        var media: [Media] = []
        
        media += self.event.mediaCollections.allMedia()
        
        if let page {
            media += page.mediaCollections.allMedia()
        }
        
        return media
    }
    
    private func collectMediaFilteringNotLoaded() -> [Media] {
        
        return collectMedia()
            .filter { (media: Media) in
                
                if let urlString = media.fullURL, let url = URL(string: urlString) {
                    return !ImagePipeline.shared.cache.containsCachedImage(
                        for: ImageRequest(url: url),
                        caches: .disk
                    )
                }
                
                return false
            }
        
    }
    
    struct LoadingConfiguration {
        public let downloadContent: Bool
        public let downloadMedia: Bool
    }
    
}

struct DownloadEventRow: View {
    
    @ObservedObject var viewModel: DownloadEventViewModel
    
    public init(viewModel: DownloadEventViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(viewModel.event.name)
                .fontWeight(.medium)
                .lineLimit(1)
            //                .redacted(reason: viewModel.event.value == nil ? .placeholder : [])
            
            HStack(spacing: 8) {
                contentState()
                mediaState()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    func contentState() -> some View {
        
        HStack(spacing: 4) {
            
            viewModel.content.hasResource { (isDownloaded: Bool) in
                
                Text(EventPackageStrings.Download.content)
                    .foregroundColor(isDownloaded ? Color.green : Color.red)
                
                Image(systemName: isDownloaded ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(isDownloaded ? Color.green : Color.red)
                
                
            }
            
            viewModel.content.isLoading {
                
                Text(EventPackageStrings.Download.content)
                
                ProgressView().progressViewStyle(.circular)
                
            }
            
        }
        
        
    }
    
    @ViewBuilder
    func mediaState() -> some View {
        
        HStack(spacing: 4) {
            
            viewModel.media.hasResource { (isDownloaded: Bool) in
                
                Text(EventPackageStrings.Download.media)
                    .foregroundColor(isDownloaded ? Color.green : Color.red)
                
                Image(systemName: isDownloaded ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(isDownloaded ? Color.green : Color.red)
                
            }
            
            viewModel.media.isLoading {
                
                Text(EventPackageStrings.Download.media)
                
                ProgressView().progressViewStyle(.circular)
                
            }
            
        }
        
        
    }
    
}
