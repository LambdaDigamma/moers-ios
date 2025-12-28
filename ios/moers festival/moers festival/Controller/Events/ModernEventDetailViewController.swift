//
//  ModernEventDetailViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 19.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import UIKit
import MapKit
import MMEvents
import MMPages
import Combine
import Resolver
import SwiftUI
import NukeUI
import MediaLibraryKit
import OSLog
import SafariServices
import Factory
import ModernNetworking

public class ModernEventDetailViewController: DefaultHostingController {
    
    public var coordinator: SharedCoordinator?
    
    private let viewModel: EventDetailViewModel
    
    private let favoriteEventsStore: FavoriteEventsStore?
    
    private let eventID: Event.ID
    private var eventService: LegacyEventService
    private var likeBarButtonItem: UIBarButtonItem?
    private var actionTransmitter = ActionTransmitter()
    private var cancellables = Set<AnyCancellable>()
    
    private let logger: Logger = Logger(.coreAppLifecycle)
    
    private var internalLikeState: Bool = false {
        didSet {
            showIsLiked(isLiked: internalLikeState)
        }
    }
    
    // MARK: - Init -
    
    public init(eventID: Event.ID, eventService: LegacyEventService? = nil) {
        self.eventID = eventID
        self.eventService = eventService ?? Resolver.resolve()
        self.viewModel = EventDetailViewModel(eventID: eventID)
        self.favoriteEventsStore = Container.shared.favoriteEventsStore()
        
        super.init()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationItems()
        self.setupListeners()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.viewModel.load()
        self.viewModel.reload()
        
    }
    
    public override func hostView() -> AnyView {
        
        ModernEventView(
            viewModel: viewModel,
            actionTransmitter: actionTransmitter,
            showDetails: {
                self.showMetadata()
            }
        )
            .toAnyView()
        
    }
    
    // MARK: - Toolbar -
    
    private func setupNavigationItems() {
        
        var rightBarButtonsItems: [UIBarButtonItem] = []
        
//        rightBarButtonsItems.append(UIBarButtonItem(
//            image: UIImage(systemName: "square.and.arrow.up"),
//            style: .plain,
//            target: self,
//            action: #selector(showSharesheet)
//        ))
        
        likeBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleLike)
        )
        
        rightBarButtonsItems.append(likeBarButtonItem!)
        
#if !os(tvOS)
        navigationItem.largeTitleDisplayMode = .never
#endif
        navigationItem.rightBarButtonItems = rightBarButtonsItems
        
    }
    
    // MARK: - Actions -
    
    @objc private func showSharesheet() {
        
        guard let page = viewModel.page, let resourceURL = page.resourceUrl else {
            return
        }
        
        guard let url = URL(string: resourceURL) else {
            return
        }

#if !os(tvOS)
        let items = [url]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
#endif
        
    }
    
    @objc private func toggleLike() {
        
        internalLikeState.toggle()
        
        Task {
            do {
                self.internalLikeState = try await favoriteEventsStore?
                    .toggleFavoriteEvent(eventID: eventID) ?? false
            } catch {
                self.logger.error("\(error.debugDescription)")
            }
        }
        
    }
    
    public func setupListeners() {
        
        actionTransmitter.showURL.sink { (url: URL) in
            
            let viewController = SFSafariViewController(url: url)
            
            self.coordinator?.navigationController.present(viewController, animated: true)
            
        }
        .store(in: &cancellables)
        
        if let favoriteEventsStore {
            
            favoriteEventsStore
                .isLiked(eventID: eventID)
                .receive(on: DispatchQueue.main)
                .sink { (completion: Subscribers.Completion<Error>) in
                    
                    if let error = completion.debugDescription {
                        self.logger.error("\(error)")
                    }
                    
                } receiveValue: { (isLiked: Bool) in
                    
                    self.internalLikeState = isLiked
                    
                }
                .store(in: &cancellables)
            
        }
        
    }
    
    private func showIsLiked(isLiked: Bool) {
        
        DispatchQueue.main.async {
            
            let imageName = isLiked ? "heart.fill" : "heart"
            
            self.likeBarButtonItem?.image = UIImage(systemName: imageName)
            
        }
        
    }
    
    private func showMetadata() {
        
        let metadata = EventMetadataScreen(
            viewModel: viewModel) { (placeID: Place.ID) in
                self.coordinator?.pushPlaceDetail(placeID: placeID)
            }
        
        let hosting = UIHostingController(rootView: metadata)
        
        hosting.modalPresentationStyle = .formSheet
        
        self.present(hosting, animated: true)
        
    }
    
}

struct ModernEventDetailViewController_Previews: PreviewProvider {
    
    static let eventService: LegacyEventService = {
        return LegacyStaticEventService()
    }()
    
    static var previews: some View {
        
        UINavigationController(
            rootViewController: ModernEventDetailViewController(
                eventID: 1,
                eventService: eventService
            )
        )
        .preview
        .preferredColorScheme(.dark)
        
    }
    
}
