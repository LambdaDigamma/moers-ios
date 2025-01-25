//
//  EventDetailView.swift
//  MMUI
//
//  Created by Lennart Fischer on 13.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Core
import UIKit
import MapKit
import AVFoundation
import Nuke
import NukeUI
import Combine

// TODO: Add Support for Moving Acts

public let readableContentConstant: CGFloat = 20

#if canImport(UIKit)
import UIKit

extension UIFont {
    
    public static func preferredFont(
        for style: TextStyle,
        weight: Weight,
        compatibleWith traitCollection: UITraitCollection? = nil
    ) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style, compatibleWith: traitCollection)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
    
}

#endif


public struct EventDetailViewConfig: Codable {
    
    public var showImage: Bool = true
    public var showLocation: Bool = true
    public var showVideo: Bool = false
    public var videoURL: URL? = nil
    
    public init() {}
    
    public init(showImage: Bool = true, showLocation: Bool = true, showVideo: Bool = false, videoURL: URL? = nil) {
        self.showImage = showImage
        self.showLocation = showLocation
        self.showVideo = showVideo
        self.videoURL = videoURL
    }
    
}

open class EventDetailView: UIView, MKMapViewDelegate {
    
    // MARK: - Properties
    
    public var viewModel: EventDetailsViewModel
    private var imageHeightAnchor: NSLayoutConstraint!
    
    public init(viewModel: EventDetailsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupEvent()
        self.setupTextViews()
        self.setupAccessibility()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player?.pause()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI
    
    public var navigationAction: (() -> Void)?
    public var websiteAction: (() -> Void)?
    public var reminderAction: (() -> Void)?
    
    private var player: AVPlayer!
    
    private lazy var scrollView = { ViewFactory.scrollView() }()
    private lazy var contentView = { ViewFactory.blankView() }()
    private lazy var layoutStack = { ViewFactory.stackView() }()
    private lazy var containerView: UIView = ViewFactory.blankView()
//    private lazy var pageView = { ViewFactory.pageView() }()
    private lazy var videoPlayerView = { ViewFactory.videoPlayerView() }()
    private lazy var imageView = { ViewFactory.imageView() }()
    private lazy var titleLabel = { ViewFactory.paddingLabel() }()
    private lazy var subtitleLabel = { ViewFactory.paddingLabel() }()
    private lazy var detailsTextView = { ViewFactory.textView() }()
    private lazy var websiteButton = { ViewFactory.roundedButton() }()
//    private lazy var locationViewContainer = {
//        ContainerView(
//            contentView: locationView,
//            edgeInsets: UIEdgeInsets(
//                top: 0,
//                left: eventDetailMargin,
//                bottom: 0,
//                right: eventDetailMargin
//            )
//        )
//    }()
//    private lazy var locationView = { ViewFactory.locationRowView() }()
    private lazy var reminderButton = { ViewFactory.roundedButton() }()
    private lazy var ticketInfoTextView = { ViewFactory.textView() }()
    private lazy var noInformationLabel = { ViewFactory.paddingLabel() }()
    
    private lazy var leftSeparator: UIView = { ViewFactory.blankView() }()
    private lazy var rightSeparator: UIView = { ViewFactory.blankView() }()
    
    
    // MARK: - Common UI Setup
    
    private func setupUI() {
        
        self.addSubviews()
        self.setupLayoutStack()
        self.setupSectionHeader()
        self.setupSectionLocation()
        self.setupSectionInfo()
        
        self.websiteButton.setTitle(String.localized("MoreInformation"), for: .normal)
        self.websiteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.websiteButton.titleLabel?.minimumScaleFactor = 0.5
        
        self.websiteButton.addAction(UIAction(handler: { _ in
            self.websiteAction?()
        }), for: .touchUpInside)
        
        self.reminderButton.setTitle("Erinnerung einrichten", for: .normal)
        self.reminderButton.isHidden = true
        
        self.reminderButton.addAction(UIAction(handler: { _ in
            self.reminderAction?()
        }), for: .touchUpInside)
        
    }
    
    private func setupConstraints() {
        
        let readable = self.readableContentGuide
        
        let contentConstraints: [NSLayoutConstraint] = [
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 64),
            scrollView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            layoutStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            layoutStack.leadingAnchor.constraint(equalTo: readable.leadingAnchor, constant: -20),
            layoutStack.trailingAnchor.constraint(equalTo: readable.trailingAnchor, constant: 20),
            layoutStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leftSeparator.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            leftSeparator.trailingAnchor.constraint(equalTo: readable.leadingAnchor, constant: -readableContentConstant),
            leftSeparator.widthAnchor.constraint(equalToConstant: 2),
            leftSeparator.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            rightSeparator.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            rightSeparator.leadingAnchor.constraint(equalTo: readable.trailingAnchor, constant: readableContentConstant),
            rightSeparator.widthAnchor.constraint(equalToConstant: 2),
            rightSeparator.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(contentConstraints)
        
    }
    
    private func addSubviews() {
        
        self.addSubview(scrollView)
        self.scrollView.addSubview(containerView)
        self.containerView.addSubview(layoutStack)
        self.containerView.addSubview(leftSeparator)
        self.containerView.addSubview(rightSeparator)
        
    }
    
    private func setupEvent() {
        
        // ???: - Work with Reactive Things here?
        
        viewModel.title.assign(to: \.text, on: titleLabel).store(in: &cancellables)
        viewModel.subtitle.assign(to: \.text, on: subtitleLabel).store(in: &cancellables)
        viewModel.hideTicketText.assign(to: \.isHidden, on: ticketInfoTextView).store(in: &cancellables)
        
        viewModel.imageURL.sink { (url: URL?) in
//            NukeUI.loadImage(with: url, into: self.imageView)
        }.store(in: &cancellables)
        
        /// Accessibility
        
        viewModel.subtitle.sink { (value: String?) in
            self.subtitleLabel.accessibilityLabel = String.localized("EventDetailViewControllerSubtitleLabel")
            self.subtitleLabel.accessibilityValue = value
        }.store(in: &cancellables)
        
        self.viewModel.description.assign(to: \.text, on: self.detailsTextView).store(in: &cancellables)
        
//        viewModel.page.observeNext { (page: Page?) in
//            if let page = page {
//                let viewModel = PageViewModel(page)
//                self.pageView.viewModel = viewModel
//            } else {
//                self.viewModel.description.bind(to: self.detailsTextView)
//            }
//        }.dispose(in: bag)
        
        viewModel.streamURL
            .receive(on: DispatchQueue.main)
            .sink { streamURL in
                self.setupPlayer()
            }
            .store(in: &cancellables)
        
    }
    
    private func setupLayoutStack() {
        
        self.layoutStack.axis = .vertical
        self.layoutStack.spacing = 8
        
        // Video
        self.layoutStack.addArrangedSubview(self.videoPlayerView)
        self.layoutStack.setCustomSpacing(8, after: self.videoPlayerView)
        
        let constraint = self.videoPlayerView.heightAnchor
            .constraint(equalTo: self.videoPlayerView.widthAnchor, multiplier: 9/16)
            
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        NSLayoutConstraint.activate([
            self.videoPlayerView.leadingAnchor.constraint(equalTo: layoutStack.leadingAnchor),
            self.videoPlayerView.trailingAnchor.constraint(equalTo: layoutStack.trailingAnchor)
        ])
        
        self.imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.layoutStack.addArrangedSubview(self.imageView)
        self.layoutStack.setCustomSpacing(8, after: self.imageView)
        
        self.noInformationLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.noInformationLabel.textInsets = UIEdgeInsets(top: 20,
                                                          left: eventDetailMargin,
                                                          bottom: 0,
                                                          right: eventDetailMargin)
        self.noInformationLabel.text = String.localized("NoEventInformation")
        self.noInformationLabel.textAlignment = .center
        self.layoutStack.addArrangedSubview(self.noInformationLabel)
        
        // Title / Subtitle Label
        self.titleLabel.textInsets = UIEdgeInsets(top: 12,
                                                  left: eventDetailMargin,
                                                  bottom: 0,
                                                  right: eventDetailMargin)
        self.subtitleLabel.textInsets = UIEdgeInsets(top: 0,
                                                     left: eventDetailMargin,
                                                     bottom: 0,
                                                     right: eventDetailMargin)
        self.layoutStack.addArrangedSubview(self.titleLabel)
        self.layoutStack.setCustomSpacing(4, after: self.titleLabel)
        self.layoutStack.addArrangedSubview(self.subtitleLabel)
        self.layoutStack.setCustomSpacing(8, after: self.subtitleLabel)
        
//        self.layoutStack.addArrangedSubview(self.pageView)
//        self.layoutStack.setCustomSpacing(16, after: self.pageView)
        self.layoutStack.addArrangedSubview(self.detailsTextView)
        self.layoutStack.setCustomSpacing(16, after: self.detailsTextView)
        
        self.websiteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.layoutStack.addArrangedSubview(self.websiteButton)
        
        self.layoutStack.addArrangedSubview(self.ticketInfoTextView)
        
//        self.layoutStack.addArrangedSubview(self.locationViewContainer)
//        self.layoutStack.setCustomSpacing(16, after: self.locationViewContainer)
        
        viewModel.showVideo.map { !$0 }.assign(to: \.isHidden, on: videoPlayerView).store(in: &cancellables)
        viewModel.showImage.map { !$0 }.assign(to: \.isHidden, on: imageView).store(in: &cancellables)
        viewModel.showPage.assign(to: \.isHidden, on: detailsTextView).store(in: &cancellables)
        
        viewModel.showMore.map { !$0 }.assign(to: \.isHidden, on: websiteButton).store(in: &cancellables)
        viewModel.showTicketInfo.map { !$0 }.assign(to: \.isHidden, on: ticketInfoTextView).store(in: &cancellables)
        viewModel.showNoInformtation.map { !$0 }.assign(to: \.isHidden, on: noInformationLabel).store(in: &cancellables)
        
    }
    
    private func resetLayoutStack() {
        layoutStack.arrangedSubviews.forEach { layoutStack.removeArrangedSubview($0) }
    }
    
    private func setupTheming() {
        
#if !os(tvOS)
        self.backgroundColor = UIColor.systemBackground
#endif
        
        self.titleLabel.textColor = UIColor.label
        self.subtitleLabel.textColor = UIColor.secondaryLabel
        self.detailsTextView.textColor = UIColor.secondaryLabel
        self.detailsTextView.backgroundColor = .clear
        self.detailsTextView.tintColor = EventPackageConfiguration.accentColor
        self.websiteButton.backgroundColor = EventPackageConfiguration.accentColor
        self.websiteButton.setTitleColor(EventPackageConfiguration.onAccentColor, for: .normal)
        self.reminderButton.backgroundColor = EventPackageConfiguration.accentColor
        self.reminderButton.setTitleColor(EventPackageConfiguration.onAccentColor, for: .normal)
        self.ticketInfoTextView.backgroundColor = .clear
        self.ticketInfoTextView.textColor = UIColor.secondaryLabel
        self.ticketInfoTextView.tintColor = EventPackageConfiguration.accentColor
        self.noInformationLabel.textColor = UIColor.label
        self.leftSeparator.backgroundColor = UIColor.separator
        self.leftSeparator.alpha = 0.5
        self.rightSeparator.backgroundColor = UIColor.separator
        self.rightSeparator.alpha = 0.5
        
    }
    
    private func setupTextViews() {
        
        let nullInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let textInsets = UIEdgeInsets(top: 0, left: eventDetailMargin, bottom: 0, right: eventDetailMargin)
        
        self.detailsTextView.contentInset = nullInsets
        self.detailsTextView.textContainerInset = textInsets
        self.detailsTextView.textContainer.lineFragmentPadding = 0
        
        self.ticketInfoTextView.contentInset = nullInsets
        self.ticketInfoTextView.textContainerInset = textInsets
        self.ticketInfoTextView.textContainer.lineFragmentPadding = 0
        
        self.detailsTextView.sizeToFit()
        
    }
    
    private func setupSectionHeader() {
        
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        
        self.titleLabel.font = .preferredFont(for: .title3, weight: .semibold, compatibleWith: .current) // UIFont.boldSystemFont(ofSize: 24)
        self.titleLabel.numberOfLines = 0
        
        self.subtitleLabel.font = .preferredFont(forTextStyle: .body, compatibleWith: .current) // UIFont.systemFont(ofSize: 16)
        self.subtitleLabel.numberOfLines = 0
        
        self.detailsTextView.font = .preferredFont(forTextStyle: .body, compatibleWith: .current)
        
        self.detailsTextView.isSelectable = true
        self.detailsTextView.isScrollEnabled = false
        
        #if !os(tvOS)
        self.detailsTextView.dataDetectorTypes = .all
        self.detailsTextView.isEditable = false
        #endif
        
    }
    
    private func setupSectionLocation() {
        
//        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLocationRowView(_:))))
        
    }
    
    private func setupSectionInfo() {
        
        self.ticketInfoTextView.font = UIFont.systemFont(ofSize: 14)
        self.ticketInfoTextView.isSelectable = false
        self.ticketInfoTextView.isScrollEnabled = false
        self.ticketInfoTextView.text = String.localized("TicketMoerzzInfo")
        
        #if !os(tvOS)
        self.ticketInfoTextView.isEditable = false
        #endif
        
    }
    
    private func setupAccessibility() {
        
        self.titleLabel.accessibilityIdentifier = "EventDetail.Title"
        self.titleLabel.accessibilityLanguage = "de-DE"
        
    }
    
    // MARK: - Video Player
    
    private func setupPlayer() {
        
        if let videoURL = viewModel.config?.videoURL {
            self.player = AVPlayer(url: videoURL)
            self.videoPlayerView.player = player
            self.player?.play()
        }
        
    }
    
    public func continuePlayback() {
        self.player?.play()
    }
    
    public func pausePlayback() {
        self.player?.pause()
    }
    
    // MARK: - Actions
    
    @objc private func didTapLocationRowView(_ locationRowView: LocationRowView) {
        self.navigationAction?()
    }
    
    // MARK: - MapKit
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "identifier"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
            annotationView?.canShowCallout = true
            
        } else {
            
            annotationView?.annotation = annotation
            
        }
        
        return annotationView
        
    }
    
}
