//
//  PlayerViewController.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 27.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import Foundation
import AVKit
import MMEvents
import Resolver
import Combine

class PlayerViewController: AVPlayerViewController {
    
    @LazyInjected var eventService: MMEvents.LegacyEventService
    
    private var livestreamData: MMEvents.LivestreamData!
    
    private var eventChangeTimer: Timer!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadStreamConfig()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.eventChangeTimer?.invalidate()
        
    }
    
    // MARK: - Load Stream
    
    private func loadStreamConfig() {
        
        let streamConfig = eventService.loadStream()
            .map({ (config: MMEvents.StreamConfig) in
                return MMEvents.LivestreamData(streamConfig: config, events: config.events)
            })
        //        .filter({ !$0.events.isEmpty })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        streamConfig.sink { [weak self] completion in
            
            switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.showInactive()
                    break
                default: break
            }
            
        } receiveValue: { (livestreamData: LivestreamData) in
            
            self.livestreamData = livestreamData

            print(livestreamData)

            if livestreamData.streamConfig.shouldShowCountdown {
                self.showCountdown()
            } else {

                if livestreamData.streamConfig.streamURL != nil {
                    self.showPlayback(livestreamData: livestreamData)
                } else {
                    self.showInactive()
                }

            }
            
        }
        .store(in: &cancellables)
        
    }
    
    // MARK: - State Management
    
    public func showCountdown() {
        
        self.performSegue(withIdentifier: Segues.countdown.rawValue, sender: self)
        
    }
    
    public func showPlayback(livestreamData: MMEvents.LivestreamData) {
        
        self.updateActiveStream(livestreamData)
        self.setupPlayback(livestreamData: livestreamData)
        
    }
    
    public func showInactive() {
        
        self.performSegue(withIdentifier: Segues.inactive.rawValue, sender: self)
        
    }
    
    // MARK: - Playback
    
    func setupPlayback(livestreamData: MMEvents.LivestreamData) {
        
        if let streamURL = livestreamData.streamConfig.processedStreamURL {
            
            let player = AVPlayer(url: streamURL)
                
            if let activeEvent = livestreamData.activeEvent {
                player.currentItem?.externalMetadata = makeExternalMetadata(event: activeEvent.model)
            }
            
            self.player = player
            self.player?.play()
            
        } else {
            
            self.player?.pause()
            self.player?.currentItem?.externalMetadata = []
            
        }
        
    }
    
    func makeExternalMetadata(event: MMEvents.Event) -> [AVMetadataItem] {
        
        var metadata = [AVMetadataItem]()
        
        // Build title item
        let titleItem = makeMetadataItem(.commonIdentifierTitle, value: event.name)
        metadata.append(titleItem)
        
        // Build artwork item
        // TODO: Add Artwork
//        do {
//            
//            if let imageURL = event.image {
//                let image = UIImage(data: try Data(contentsOf: imageURL))
//
//                if let image = image, let pngData = image.pngData() {
//                    let artworkItem = makeMetadataItem(.commonIdentifierArtwork, value: pngData)
//                    metadata.append(artworkItem)
//                }
//            }
//
//        } catch {
//            print(error.localizedDescription)
//        }
        
        // Build description item
        let descItem = makeMetadataItem(.commonIdentifierDescription, value: event.description ?? "No description available.")
        metadata.append(descItem)
        
        // Build genre item
        let genreItem = makeMetadataItem(.quickTimeMetadataGenre, value: "Music")
        metadata.append(genreItem)
        return metadata
        
    }
    
    private func makeMetadataItem(_ identifier: AVMetadataIdentifier, value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
    
    private func setupEventViewTimer(at date: Date) {
        
        print("event change: \(date)")
        
        self.eventChangeTimer = Timer(
            fireAt: date.addingTimeInterval(2),
            interval: 0,
            target: self,
            selector: #selector(changeToActiveEvent),
            userInfo: nil,
            repeats: false
        )
        
        RunLoop.main.add(self.eventChangeTimer, forMode: .common)
        
    }
    
    private func updateActiveStream(_ livestreamData: MMEvents.LivestreamData) {
        
        if let activeEvent = livestreamData.activeEvent {
            self.player?.currentItem?.externalMetadata = makeExternalMetadata(event: activeEvent.model)
        } else {
            self.player?.currentItem?.externalMetadata = []
        }
        
        if let endDate = livestreamData.activeEvent?.model.endDate {
            print("--- There is an 'next' active event.")
            self.setupEventViewTimer(at: endDate)
        } else {
            
            if let nextEvent = livestreamData.events
                .map({ $0.model })
                .filter({ $0.startDate != nil })
                .filter({ $0.startDate ?? Date(timeIntervalSinceNow: -3600) > Date() })
                .chronologically()
                .first {
                
                if let startDate = nextEvent.startDate {
                    print("set new timer at startdate")
                    self.setupEventViewTimer(at: startDate)
                } else {
                    self.setupEventViewTimer(at: Date().addingTimeInterval(60 * 5))
                }
                
            } else {
                self.setupEventViewTimer(at: Date().addingTimeInterval(60 * 5))
            }
            
        }
        
    }
    
    // MARK: - Timer Actions
    
    /// This method is being called by the `eventChangeTimer` to change the actively displayed event.
    @objc private func changeToActiveEvent() {
        
        if livestreamData.streamConfig.streamURL != nil {
            
            self.updateActiveStream(livestreamData)
            
        } else {
            self.showInactive()
        }
        
        print("Change to next active event")
        
    }
    
    // MARK: - Navigation
    
    public enum Segues: String {
        case countdown = "showCountdown"
        case inactive = "showInactive"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segues.countdown.rawValue {
            if let viewController = segue.destination as? CountdownViewController,
                livestreamData != nil {
                viewController.livestreamData = livestreamData
                viewController.fireCompletion = {
                    self.loadStreamConfig()
                }
            }
        } else if segue.identifier == Segues.inactive.rawValue {
            if let viewController = segue.destination as? InactiveStreamViewController,
                livestreamData != nil {
                viewController.livestreamData = livestreamData
                viewController.reloadAction = {
                    self.loadStreamConfig()
                }
            }
        }
        
    }
    
}
