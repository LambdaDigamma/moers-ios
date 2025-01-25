//
//  DownloadEventsScreen.swift
//  
//
//  Created by Lennart Fischer on 04.05.23.
//

import SwiftUI
import Core
import Factory
import Combine

class DownloadEventsViewModel: StandardViewModel {
    
    private let repository: EventRepository
    
    @Published var events: [DownloadEventViewModel] = []
    
    @Published var downloadContent: Bool = true
    @Published var downloadMedia: Bool = false
    
    public override init() {
        repository = Container.shared.eventRepository()
    }
    
    public func load() {
        
        repository.store
            .observeAllEvents()
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (events: [EventRecord]) in
                
                self.events = events.map({ (event: EventRecord) in
                    DownloadEventViewModel(
                        eventID: event.id.toInt() ?? 0,
                        event: event
                    )
                })
                
            }
            .store(in: &cancellables)
        
    }
    
    public func download() {
        
        Task {
            
            do {
                
                for event in events {
                    event.setContentState(.loading)
                }
                
                try await downloadEventsWithPages()
                
            } catch {
                
                for event in events {
                    event.setContentState(.success(false))
                }
                
            }
            
            for event in events {
                
                event.setContentState(.success(true))
                
                event.download(
                    loadingConfiguration: DownloadEventViewModel.LoadingConfiguration(
                        downloadContent: downloadContent,
                        downloadMedia: downloadMedia
                    )
                )
                
            }
            
        }
        
    }
    
    private func downloadEventsWithPages() async throws {
        
        try await repository.refreshEvents(withPages: true)
        
    }
    
}

public struct DownloadEventsScreen: View {
    
    @StateObject var viewModel = DownloadEventsViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        
        List {
            
            Section {
                
                Toggle(EventPackageStrings.Download.downloadContent, isOn: $viewModel.downloadContent)
                
                Toggle(EventPackageStrings.Download.downloadMedia, isOn: $viewModel.downloadMedia)
                
                Button(action: {
                    viewModel.download()
                }) {
                    Text(EventPackageStrings.Download.downloadTimetable)
                }
                
            } header: {
                Text(EventPackageStrings.Download.downloadHeader)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } footer: {
                Text(EventPackageStrings.Download.downloadFooter)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Section {
                
                ForEach(viewModel.events, id: \.eventID) { (event: DownloadEventViewModel) in
                    
                    DownloadEventRow(
                        viewModel: event
                    )
                    
                }
                
            } header: {
                Text(EventPackageStrings.Download.downloadHeader)
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.load()
        }
        
    }
    
}

struct DownloadEventsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DownloadEventsScreen()
    }
}
