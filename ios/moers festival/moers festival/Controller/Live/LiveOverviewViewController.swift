//
//  LiveOverviewViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import MMEvents
import AVKit
import StateViewController
import OSLog
import Combine
import Factory

class LiveOverviewViewController: StateViewController<LivestreamState> {
    
    public var coordinator: LiveCoordinator?
    
    @LazyInjected(\.legacyEventService) var eventService
    
    private lazy var loadingController =  { LoadingViewController(loadingHint: String.localized("LoadingLivestream")) }()
    private lazy var activeStreamViewController = { ActiveStreamViewController() }()
    private lazy var inactiveStreamViewController = { InactiveStreamViewController() }()
    
    private let logger = Logger(.default)
    
    private var cancellables = Set<AnyCancellable>()
    
    private var updateInterval: TimeInterval = 60.0
    private var updateCheckTimer: Timer!
    private var countdownTimer: Timer!
    private var eventChangeTimer: Timer!
    
    private var livestreamData: LivestreamData?
    
    // MARK: - UIViewController Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTheming()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.updateCheckTimer?.invalidate()
        self.countdownTimer?.invalidate()
        self.eventChangeTimer?.invalidate()
        
    }
    
    private func setupUI() {
        
        self.title = "Live"
    
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor.systemBackground
        
    }
    
    // MARK: - State: Countdown -
    
    private func setupCountdownTimer(startDate: Date) {
        
        self.countdownTimer = Timer(
            fireAt: startDate, interval: 0,
            target: self, selector: #selector(transitionToLiveStream),
            userInfo: nil, repeats: false
        )
        
        RunLoop.main.add(self.countdownTimer, forMode: .common)
        
    }
    
    private func reloadStreamURL() {
        
        let streamConfig = eventService.loadStream()
            .map { (config: MMEvents.StreamConfig) in
                return MMEvents.LivestreamData(streamConfig: config, events: config.events)
            }
//        .filter({ !$0.events.isEmpty })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        streamConfig.sink { [weak self] (completion: Subscribers.Completion<Publishers.Map<AnyPublisher<MMEvents.StreamConfig, Error>, MMEvents.LivestreamData>.Failure>) in

            switch completion {
                case .failure(let error):
                    self?.logger.error("An error occured: \(error.localizedDescription)")
                    self?.setInactiveState()
                default: break
            }

        } receiveValue: { [weak self] (data: MMEvents.LivestreamData) in

            self?.livestreamData = data
            self?.processLivestreamData(data)

        }
        .store(in: &cancellables)
        
    }
    
    private func processLivestreamData(_ livestreamData: LivestreamData) {
        
        if let startDate = livestreamData.streamConfig.startDate {

            if Date() < startDate {
                self.setNeedsStateTransition(to: .countdown(startDate: startDate), animated: true)
                self.setupCountdownTimer(startDate: startDate)
            } else {
                
                if let _ = livestreamData.streamConfig.streamURL {
                    self.setNeedsStateTransition(to: .activeStream(livestreamData: livestreamData), animated: true)
                    self.updateCheckTimer?.invalidate()
                } else {
                    self.setInactiveState()
                }
            }

        } else {
            self.setInactiveState()
        }
        
    }
    
    private func setupEventViewTimer(at date: Date) {
        
        logger.info("Event Change: \(date)")
        
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
    
    private func setInactiveState() {
        
        self.setNeedsStateTransition(to: .inactiveStream, animated: true)
        
        self.updateCheckTimer = Timer.scheduledTimer(
            timeInterval: updateInterval,
            target: self,
            selector: #selector(updateUI),
            userInfo: nil,
            repeats: true
        )
        
    }
    
    private func updateActiveStream(_ livestreamData: LivestreamData, stream: ActiveStream) {
        
        self.activeStreamViewController.updateActiveStream(stream)
        
        if let endDate = livestreamData.activeEvent?.model.endDate {
            
            logger.log("There is an 'next' active event.")
            
            self.setupEventViewTimer(at: endDate)
            
        } else {
            
            if let nextEvent = livestreamData.events
                .map({ $0.model })
                .filter({ $0.startDate != nil })
                .filter({ $0.startDate ?? Date(timeIntervalSinceNow: -3600) > Date() })
                .chronologically()
                .first {
                
                if let startDate = nextEvent.startDate {
                    
                    logger.log("Set new timer at start date \(startDate)")
                    
                    self.setupEventViewTimer(at: startDate)
                } else {
                    self.setupEventViewTimer(at: Date().addingTimeInterval(60 * 5))
                }
                
            } else {
                self.setupEventViewTimer(at: Date().addingTimeInterval(60 * 5))
            }
            
        }
        
    }
    
    // MARK: - Timer Actions -
    
    /// This method is being called by the `countdownTimer`
    /// to transition the _activeStream_ state when countdown is over.
    @objc private func transitionToLiveStream() {
        
        logger.log("Transition")
        
        guard let livestreamData = livestreamData else { return }
        
        self.setNeedsStateTransition(to: .activeStream(livestreamData: livestreamData), animated: true)
        
    }
    
    /// This method is being called by the `eventChangeTimer`
    /// to change the actively displayed event.
    @objc private func changeToActiveEvent() {
        
        switch self.currentState {
            
        case .activeStream(let livestreamData):
            
            if let url = URL(string: livestreamData.streamConfig.streamURL ?? "") {
                
                let stream = MMEvents.ActiveStream(streamURL: url, activeEvent: livestreamData.activeEvent?.model)
                self.updateActiveStream(livestreamData, stream: stream)
                
            } else {
                self.setInactiveState()
            }
            
        default:
            break
            
        }
        
        logger.log("Change to next active event")
        
    }
    
    /// This method is being called by the `updateTimer`
    /// when livestream is in inactive state to check for new data.
    @objc private func updateUI() {
        
        logger.log("Updating")
        
        reloadStreamURL()
        
    }
    
    // MARK: - State Handling -
    
    override func loadAppearanceState() -> LivestreamState {
        return .loading
    }
    
    override func children(for state: LivestreamState) -> [UIViewController] {
        
        switch state {
            
        case .loading:

            return [
                loadingController
            ]
            
        case .countdown(let startDate):
            return [
                CountdownViewController(startDate: startDate)
            ]
            
        case .activeStream:
            return [
                activeStreamViewController
            ]
            
        case .inactiveStream:
            return [
                inactiveStreamViewController
            ]
            
        }
        
    }
    
    override func didTransition(from previousState: LivestreamState?, animated: Bool) {
        
        switch currentState {
            
        case .loading:
            reloadStreamURL()
            
        case .countdown:
            AnalyticsManager.shared.logCountdown()
            
        case .activeStream(let livestreamData):
            
            if let url = URL(string: livestreamData.streamConfig.streamURL ?? "") {
                
                logger.log("Reloaded State")
                
                let stream = ActiveStream(streamURL: url, activeEvent: livestreamData.activeEvent?.model)
                self.updateActiveStream(livestreamData, stream: stream)
                
                AnalyticsManager.shared.logActiveStream()
                
            }
            
        default:
            break
        }
        
    }
    
    override func willTransition(to nextState: LivestreamState, animated: Bool) {
        
        
    }
    
}
