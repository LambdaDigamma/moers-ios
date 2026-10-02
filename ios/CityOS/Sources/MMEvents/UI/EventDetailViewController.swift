//
//  EventDetailViewController.swift
//  
//
//  Created by Lennart Fischer on 14.06.21.
//

#if canImport(UIKit)
import Core
import UIKit
import MapKit

#if !os(tvOS)
import SafariServices
#endif

open class EventDetailViewController: UIViewController {
    
    public let viewModel: EventDetailsViewModel
    private let eventDetailView: EventDetailView
    private var previousStandardAppearance: UINavigationBarAppearance?
    private var previousScrollEdgeAppearance: UINavigationBarAppearance?
    private var previousCompactAppearance: UINavigationBarAppearance?
    private var previousTintColor: UIColor?
    private var previousIsTranslucent: Bool?
    
    public init(viewModel: EventDetailsViewModel) {
        self.viewModel = viewModel
        self.eventDetailView = EventDetailView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override open func loadView() {
        view = eventDetailView
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureTransparentNavigationBar()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        restoreNavigationBar()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
         
//        self.title = String(localized: "Details", bundle: .module)
        
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
#if !os(tvOS)
        self.navigationItem.largeTitleDisplayMode = .never
#endif
        
        self.eventDetailView.navigationAction = navigationAction
        self.eventDetailView.websiteAction = websiteAction
        self.eventDetailView.reminderAction = reminderAction
        
        let isLiked = viewModel.isLiked
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleHeart(barButtonItem:))
        )
        
    }

    private func configureTransparentNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }

        previousStandardAppearance = navigationBar.standardAppearance.copy()
        previousScrollEdgeAppearance = navigationBar.scrollEdgeAppearance?.copy()
        previousCompactAppearance = navigationBar.compactAppearance?.copy()
        previousTintColor = navigationBar.tintColor
        previousIsTranslucent = navigationBar.isTranslucent

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .label
    }

    private func restoreNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }

        if let previousStandardAppearance {
            navigationBar.standardAppearance = previousStandardAppearance
        }

        navigationBar.scrollEdgeAppearance = previousScrollEdgeAppearance

        if let previousCompactAppearance {
            navigationBar.compactAppearance = previousCompactAppearance
        }

        if let previousTintColor {
            navigationBar.tintColor = previousTintColor
        }

        if let previousIsTranslucent {
            navigationBar.isTranslucent = previousIsTranslucent
        }
    }
    
    // MARK: - UI Actions
    
    private func navigationAction() {
        
        let _ = viewModel.model
        
        // TODO: 
        
//        if let event = event {
//
//            let viewModel = EventViewModel(event: event)
//
//            viewModel.locationRepresentation
//
//            let preview = LocationPreviewModel(
//                name: event.getLocation()?.name ?? event.extras?.location ?? "",
//                coordinate: event.getLocation()?.coordinate ?? event.extras?.coordinate,
//                street: event.getLocation()?.street ?? event.extras?.street,
//                houseNumber: event.getLocation()?.houseNumber ?? event.extras?.houseNumber,
//                postcode: event.getLocation()?.postcode ?? event.extras?.postcode,
//                place: event.getLocation()?.place ?? event.extras?.place
//            )
//
//            let locationPreviewViewModel = LocationPreviewViewModel(model: preview)
//            let locationPreviewViewController = LocationPreviewViewController(viewModel: locationPreviewViewModel)
//
//            self.navigationController?.pushViewController(locationPreviewViewController, animated: true)
//
//        }
        
    }
    
    private func websiteAction() {
        
        #if !os(tvOS)
        if let url = viewModel.webURL {
            
            let svc = SFSafariViewController(url: url)
            svc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
            svc.preferredControlTintColor = navigationController?.navigationBar.tintColor
            self.present(svc, animated: true, completion: nil)
            
        }
        #endif
        
    }
    
    private func reminderAction() {
        
    }
    
    @objc private func toggleHeart(barButtonItem: UIBarButtonItem) {
        
        // TODO: Improve this
        // https://www.swiftbysundell.com/posts/different-flavors-of-view-models-in-swift
        
        viewModel.isLiked.toggle()
        
        let isLiked = viewModel.isLiked
        
        if isLiked {
            barButtonItem.image = UIImage(systemName: "heart.fill")
        } else {
            barButtonItem.image = UIImage(systemName: "heart")
        }
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

#endif
