//
//  ActiveStreamViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AVKit
import MMEvents
import SwiftUI
import Combine
import YouTubePlayerKit

public class ActiveStreamViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        
    }
    
    public func load() {
        
        
        
    }
    
}

class ActiveStreamViewController: UIViewController {
    
    private let eventDetailView: MMEvents.EventDetailView
    private let viewModel: MMEvents.EventDetailsViewModel
    
    init() {
        
        self.viewModel = MMEvents.EventDetailsViewModel(model: nil, config: nil)
        self.eventDetailView = MMEvents.EventDetailView(viewModel: viewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupPlayerControlActions()
        
    }
    
    init(stream: MMEvents.ActiveStream) {
        
        let config = MMEvents.EventDetailViewConfig(
            showImage: false,
            showLocation: false,
            showVideo: true,
            videoURL: stream.streamURL
        )
        
        self.viewModel = MMEvents.EventDetailsViewModel(model: stream.activeEvent, config: config)
        self.eventDetailView = MMEvents.EventDetailView(viewModel: viewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupPlayerControlActions()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = eventDetailView
    }
    
    public func updateActiveStream(_ stream: MMEvents.ActiveStream) {
        
        viewModel.setNewEvent(stream.activeEvent)
        
        if stream.streamURL != viewModel.config?.videoURL {
            let config = MMEvents.EventDetailViewConfig(
                showImage: false,
                showLocation: false,
                showVideo: true,
                videoURL: stream.streamURL
            )
            viewModel.setNewConfig(config)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTheming()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.eventDetailView.continuePlayback()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.eventDetailView.pausePlayback()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor.systemBackground
        
    }
    
    private func setupPlayerControlActions() {
        
        // TODO: where did it go?
        
//        self.eventDetailView.
        
//        self.eventDetailView.fullscreenTap.observeNext { () in
//
//            if let streamURL = self.viewModel.config?.videoURL {
//
//                self.eventDetailView.pausePlayback()
//
//                let player = AVPlayer(url: streamURL)
//                let playerViewController = AVPlayerViewController()
//                playerViewController.player = player
//                self.present(playerViewController, animated: true) {
//                    playerViewController.player!.play()
//                }
//
//            }
//
//        }.dispose(in: bag)
        
    }
    
}

public struct ActiveStreamScreen: View {
    
    
    @ObservedObject var player: YouTubePlayer = "https://www.youtube.com/watch?v=GLeVB_jAqP8"
    
    public var body: some View {
        
        LazyVStack(alignment: .leading) {
            
            YouTubePlayerView(player) { state in
                switch state {
                    case .idle:
                        
                        ZStack {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipped()
                            
                    case .ready:
                        EmptyView()
                    case .error(_):
                        Text(verbatim: "YouTube player couldn't be loaded")
                }
            }
            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            
            
            VStack {
                
                Text("Moritz Simon Geist \"MR-808\" (DE)")
                    .fontWeight(.semibold)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        
    }
    
}

struct ActiveStreamScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ActiveStreamScreen()
            .preferredColorScheme(.dark)
        
    }
    
}
