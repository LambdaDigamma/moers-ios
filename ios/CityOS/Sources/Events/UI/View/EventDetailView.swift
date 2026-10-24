//
//  EventDetailView.swift
//  UI
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
    public var showsFestivalSubtitle: Bool = false

    public init() {}

    public init(showImage: Bool = true, showLocation: Bool = true, showVideo: Bool = false, videoURL: URL? = nil, showsFestivalSubtitle: Bool = false) {
        self.showImage = showImage
        self.showLocation = showLocation
        self.showVideo = showVideo
        self.videoURL = videoURL
        self.showsFestivalSubtitle = showsFestivalSubtitle
    }

    private enum CodingKeys: String, CodingKey {
        case showImage, showLocation, showVideo, videoURL, showsFestivalSubtitle
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        showImage = try values.decodeIfPresent(Bool.self, forKey: .showImage) ?? true
        showLocation = try values.decodeIfPresent(Bool.self, forKey: .showLocation) ?? true
        showVideo = try values.decodeIfPresent(Bool.self, forKey: .showVideo) ?? false
        videoURL = try values.decodeIfPresent(URL.self, forKey: .videoURL)
        showsFestivalSubtitle = try values.decodeIfPresent(Bool.self, forKey: .showsFestivalSubtitle) ?? false
    }

}

open class EventDetailView: UIView, MKMapViewDelegate, UIScrollViewDelegate {

    // MARK: - Properties

    public var viewModel: EventDetailsViewModel
    private var imageHeightAnchor: NSLayoutConstraint!
    private var imageContentTopAnchor: NSLayoutConstraint!
    private var noHeaderTopSpacerHeightAnchor: NSLayoutConstraint!
    private var backgroundExtensionContentTopAnchor: NSLayoutConstraint?
    private var layoutStackTopAnchor: NSLayoutConstraint!
    private var contentWidthConstraints: [NSLayoutConstraint] = []
    private let contentHorizontalInset: CGFloat = 16
    private let contentBottomSpacing: CGFloat = 16
    private let fallbackHeaderImageAspectRatio: CGFloat = 0.78
    private let noHeaderNavigationSpacing: CGFloat = 16

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
        imageTask?.cancel()
        player?.pause()
    }

    private var cancellables = Set<AnyCancellable>()
    private var imageTask: ImageTask?
    private var hasStretchyHeader = false
    private var headerImageAspectRatio: CGFloat?
    private var lastHeaderSizingWidth: CGFloat = 0
    private var lastHeaderSizingHeight: CGFloat = 0
    private var lastHeaderTopExtensionHeight: CGFloat = 0
    private var imageHeaderUsesBackgroundExtension = false

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
    private lazy var noHeaderTopSpacerView = {
        let spacerView = ViewFactory.blankView()
        spacerView.isHidden = true
        return spacerView
    }()
    private lazy var imageHeaderView = {
        let headerView = ViewFactory.blankView()
        headerView.clipsToBounds = true
        headerView.isHidden = true
        return headerView
    }()
    private lazy var backgroundExtensionImageView = { ViewFactory.imageView() }()
    private lazy var imageView = { ViewFactory.imageView() }()
    private lazy var titleLabel = { ViewFactory.paddingLabel() }()
    private lazy var subtitleLabel = { ViewFactory.paddingLabel() }()
    private lazy var metadataStackView = UIStackView()
    private lazy var scheduleValueLabel = UILabel()
    private lazy var locationValueLabel = UILabel()
    private lazy var organizerValueLabel = UILabel()
    private lazy var scheduleInfoView = makeInfoRow(
        systemImageName: "calendar",
        title: String(localized: "Date", bundle: .module),
        valueLabel: scheduleValueLabel
    )
    private lazy var locationInfoView = makeInfoRow(
        systemImageName: "mappin.and.ellipse",
        title: String(localized: "Venue", bundle: .module),
        valueLabel: locationValueLabel
    )
    private lazy var organizerInfoView = makeInfoRow(
        systemImageName: "person.crop.circle",
        title: String(localized: "Organizer", bundle: .module),
        valueLabel: organizerValueLabel
    )
    private lazy var metadataContainerView = makeInsetContainer(metadataStackView)
    private lazy var detailsTextView = { ViewFactory.textView() }()
    private lazy var websiteButton = { ViewFactory.roundedButton() }()
    private lazy var websiteButtonContainerView = makeInsetContainer(websiteButton)
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
        self.setupScrollView()
        self.setupLayoutStack()
        self.setupSectionHeader()
        self.setupSectionLocation()
        self.setupSectionInfo()

        self.websiteButton.setTitle(String(localized: "Open Website", bundle: .module), for: .normal)
        self.websiteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.websiteButton.titleLabel?.minimumScaleFactor = 0.5

        self.websiteButton.addAction(UIAction(handler: { _ in
            self.websiteAction?()
        }), for: .touchUpInside)

        self.reminderButton.setTitle(String(localized: "Set reminder", bundle: .module), for: .normal)
        self.reminderButton.isHidden = true

        self.reminderButton.addAction(UIAction(handler: { _ in
            self.reminderAction?()
        }), for: .touchUpInside)

    }

    private func setupConstraints() {
        layoutStackTopAnchor = layoutStack.topAnchor.constraint(equalTo: containerView.topAnchor)
        let contentConstraints: [NSLayoutConstraint] = [
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            layoutStackTopAnchor,
            layoutStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            layoutStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            layoutStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leftSeparator.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            leftSeparator.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: -readableContentConstant),
            leftSeparator.widthAnchor.constraint(equalToConstant: 2),
            leftSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rightSeparator.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            rightSeparator.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: readableContentConstant),
            rightSeparator.widthAnchor.constraint(equalToConstant: 2),
            rightSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ]

        NSLayoutConstraint.activate(contentConstraints + contentWidthConstraints)

    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        updateHeaderHeight()
        updateNoHeaderTopSpacerHeight()
        updateContentSafeAreaInsets()
        // Cancel only the automatic top gap so the image still reaches behind the bar.
        layoutStackTopAnchor.constant = -scrollView.adjustedContentInset.top
    }

    override open func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()

        setNeedsLayout()
    }

    private func addSubviews() {

        self.addSubview(scrollView)
        self.scrollView.addSubview(containerView)
        self.containerView.addSubview(layoutStack)
        self.containerView.addSubview(leftSeparator)
        self.containerView.addSubview(rightSeparator)

    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        scrollView.contentInset.bottom = contentBottomSpacing
        scrollView.verticalScrollIndicatorInsets.bottom = contentBottomSpacing
    }

    private func setupEvent() {

        // ???: - Work with Reactive Things here?

        viewModel.title.assign(to: \.text, on: titleLabel).store(in: &cancellables)
        viewModel.subtitle.assign(to: \.text, on: subtitleLabel).store(in: &cancellables)
        viewModel.hideTicketText.assign(to: \.isHidden, on: ticketInfoTextView).store(in: &cancellables)

        viewModel.subtitle
            .map { ($0 ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: \.isHidden, on: subtitleLabel)
            .store(in: &cancellables)

        viewModel.event.combineLatest(viewModel.observableConfig)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.configureMetadata(for: value.0)
            }
            .store(in: &cancellables)

        viewModel.imageURL.sink { [weak self] (url: URL?) in
            self?.configureImage(url: url)
        }.store(in: &cancellables)

        /// Accessibility

        viewModel.subtitle.sink { (value: String?) in
            self.subtitleLabel.accessibilityLabel = String(localized: "Event subtitle", bundle: .module)
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
        self.layoutStack.spacing = 0

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

        noHeaderTopSpacerHeightAnchor = noHeaderTopSpacerView.heightAnchor.constraint(equalToConstant: 0)
        noHeaderTopSpacerHeightAnchor.isActive = true
        self.layoutStack.addArrangedSubview(self.noHeaderTopSpacerView)

        setupImageHeaderView()
        imageHeightAnchor = self.imageHeaderView.heightAnchor.constraint(equalToConstant: 300)
        imageHeightAnchor.isActive = true
        self.layoutStack.addArrangedSubview(self.imageHeaderView)
        self.layoutStack.setCustomSpacing(24, after: self.imageHeaderView)

        self.noInformationLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.noInformationLabel.textInsets = UIEdgeInsets(top: 24,
                                                          left: contentHorizontalInset,
                                                          bottom: 0,
                                                          right: contentHorizontalInset)
        self.noInformationLabel.text = String(localized: "No event information available", bundle: .module)
        self.noInformationLabel.textAlignment = .center
        self.layoutStack.addArrangedSubview(self.noInformationLabel)

        // Title / Subtitle Label
        self.titleLabel.textInsets = UIEdgeInsets(top: 0,
                                                  left: contentHorizontalInset,
                                                  bottom: 0,
                                                  right: contentHorizontalInset)
        self.subtitleLabel.textInsets = UIEdgeInsets(top: 0,
                                                     left: contentHorizontalInset,
                                                     bottom: 0,
                                                     right: contentHorizontalInset)
        self.layoutStack.addArrangedSubview(self.titleLabel)
        self.layoutStack.setCustomSpacing(6, after: self.titleLabel)
        self.layoutStack.addArrangedSubview(self.subtitleLabel)
        self.layoutStack.setCustomSpacing(22, after: self.subtitleLabel)

        metadataStackView.axis = .vertical
        metadataStackView.spacing = 8
        metadataStackView.translatesAutoresizingMaskIntoConstraints = false
        metadataStackView.addArrangedSubview(scheduleInfoView)
        metadataStackView.addArrangedSubview(locationInfoView)
        metadataStackView.addArrangedSubview(organizerInfoView)
        self.layoutStack.addArrangedSubview(metadataContainerView)
        self.layoutStack.setCustomSpacing(24, after: metadataContainerView)

//        self.layoutStack.addArrangedSubview(self.pageView)
//        self.layoutStack.setCustomSpacing(16, after: self.pageView)
        self.layoutStack.addArrangedSubview(self.detailsTextView)
        self.layoutStack.setCustomSpacing(24, after: self.detailsTextView)

        self.websiteButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.layoutStack.addArrangedSubview(self.websiteButtonContainerView)
        self.layoutStack.setCustomSpacing(20, after: self.websiteButtonContainerView)

        self.layoutStack.addArrangedSubview(self.ticketInfoTextView)

//        self.layoutStack.addArrangedSubview(self.locationViewContainer)
//        self.layoutStack.setCustomSpacing(16, after: self.locationViewContainer)

        viewModel.showVideo.map { !$0 }.assign(to: \.isHidden, on: videoPlayerView).store(in: &cancellables)
        viewModel.showImage
            .sink { [weak self] shouldShowImage in
                guard let self else { return }

                imageHeaderView.isHidden = !shouldShowImage
                imageView.isHidden = !shouldShowImage
                backgroundExtensionImageView.isHidden = !shouldShowImage
                hasStretchyHeader = shouldShowImage
                noHeaderTopSpacerView.isHidden = shouldShowImage
                updateNoHeaderTopSpacerHeight()

                if shouldShowImage {
                    updateHeaderHeight(force: true)
                    updateStretchyHeader(for: scrollView.contentOffset.y)
                } else {
                    resetStretchyHeader()
                }
            }
            .store(in: &cancellables)
        viewModel.showPage.assign(to: \.isHidden, on: detailsTextView).store(in: &cancellables)

        viewModel.showMore.map { !$0 }.assign(to: \.isHidden, on: websiteButtonContainerView).store(in: &cancellables)
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
        self.websiteButton.backgroundColor = UIColor.label
        self.websiteButton.setTitleColor(ApplicationTheme.current.backgroundColor, for: .normal)
        self.websiteButton.layer.cornerRadius = 14
        self.websiteButton.layer.cornerCurve = .continuous
        self.reminderButton.backgroundColor = EventPackageConfiguration.accentColor
        self.reminderButton.setTitleColor(EventPackageConfiguration.onAccentColor, for: .normal)
        self.ticketInfoTextView.backgroundColor = .clear
        self.ticketInfoTextView.textColor = UIColor.secondaryLabel
        self.ticketInfoTextView.tintColor = EventPackageConfiguration.accentColor
        self.noInformationLabel.textColor = UIColor.label
        self.leftSeparator.isHidden = true
        self.rightSeparator.isHidden = true

    }

    private func setupTextViews() {

        let nullInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let textInsets = UIEdgeInsets(top: 0, left: contentHorizontalInset, bottom: 0, right: contentHorizontalInset)

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
        self.backgroundExtensionImageView.contentMode = .scaleAspectFill
        self.backgroundExtensionImageView.clipsToBounds = true

        self.titleLabel.font = .preferredFont(for: .title1, weight: .bold, compatibleWith: .current)
        self.titleLabel.numberOfLines = 0

        self.subtitleLabel.font = .preferredFont(for: .body, weight: .medium, compatibleWith: .current)
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
        self.ticketInfoTextView.text = String(localized: "Mörzz-Ticket information", bundle: .module)

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

private extension EventDetailView {

    func updateContentSafeAreaInsets() {
        for label in [titleLabel, subtitleLabel, noInformationLabel] {
            let safeFrame = label.convert(safeAreaLayoutGuide.layoutFrame, from: self)
            var insets = label.textInsets
            insets.left = max(safeFrame.minX - label.bounds.minX, 0) + contentHorizontalInset
            insets.right = max(label.bounds.maxX - safeFrame.maxX, 0) + contentHorizontalInset
            if label.textInsets != insets {
                label.textInsets = insets
            }
        }

        for textView in [detailsTextView, ticketInfoTextView] {
            let safeFrame = textView.convert(safeAreaLayoutGuide.layoutFrame, from: self)
            var insets = textView.textContainerInset
            insets.left = max(safeFrame.minX - textView.bounds.minX, 0) + contentHorizontalInset
            insets.right = max(textView.bounds.maxX - safeFrame.maxX, 0) + contentHorizontalInset
            if textView.textContainerInset != insets {
                textView.textContainerInset = insets
            }
        }
    }

    func setupImageHeaderView() {
#if !os(watchOS)
        if #available(iOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            let backgroundExtensionView = UIBackgroundExtensionView()
            backgroundExtensionView.translatesAutoresizingMaskIntoConstraints = false
            backgroundExtensionView.isUserInteractionEnabled = false
            backgroundExtensionView.automaticallyPlacesContentView = false
            backgroundExtensionView.contentView = backgroundExtensionImageView
            imageHeaderView.addSubview(backgroundExtensionView)
            imageHeaderUsesBackgroundExtension = true
            let contentTopAnchor = backgroundExtensionImageView.topAnchor.constraint(
                equalTo: backgroundExtensionView.topAnchor
            )
            backgroundExtensionContentTopAnchor = contentTopAnchor

            NSLayoutConstraint.activate([
                backgroundExtensionView.leadingAnchor.constraint(equalTo: imageHeaderView.leadingAnchor),
                backgroundExtensionView.topAnchor.constraint(equalTo: imageHeaderView.topAnchor),
                backgroundExtensionView.trailingAnchor.constraint(equalTo: imageHeaderView.trailingAnchor),
                backgroundExtensionView.bottomAnchor.constraint(equalTo: imageHeaderView.bottomAnchor),
                backgroundExtensionImageView.leadingAnchor.constraint(equalTo: backgroundExtensionView.leadingAnchor),
                contentTopAnchor,
                backgroundExtensionImageView.trailingAnchor.constraint(equalTo: backgroundExtensionView.trailingAnchor),
                backgroundExtensionImageView.bottomAnchor.constraint(equalTo: backgroundExtensionView.bottomAnchor),
            ])
        }
#endif

        imageHeaderView.addSubview(imageView)
        imageContentTopAnchor = imageView.topAnchor.constraint(equalTo: imageHeaderView.topAnchor)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: imageHeaderView.leadingAnchor),
            imageContentTopAnchor,
            imageView.trailingAnchor.constraint(equalTo: imageHeaderView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageHeaderView.bottomAnchor),
        ])
    }

    func updateHeaderHeight(force: Bool = false) {
        guard imageHeightAnchor != nil else { return }

        let availableWidth: CGFloat
        if imageHeaderView.bounds.width > 0 {
            availableWidth = imageHeaderView.bounds.width
        } else {
            availableWidth = max(containerView.bounds.width, bounds.width)
        }
        let topExtensionHeight = headerTopExtensionHeight
        updateHeaderContentPlacement(topExtensionHeight: topExtensionHeight)

        guard availableWidth > 0, bounds.height > 0 else { return }
        guard force
            || abs(availableWidth - lastHeaderSizingWidth) > 0.5
            || abs(bounds.height - lastHeaderSizingHeight) > 0.5
            || abs(topExtensionHeight - lastHeaderTopExtensionHeight) > 0.5 else { return }

        lastHeaderSizingWidth = availableWidth
        lastHeaderSizingHeight = bounds.height
        lastHeaderTopExtensionHeight = topExtensionHeight
        imageHeightAnchor.constant = preferredHeaderHeight(for: availableWidth)
    }

    func preferredHeaderHeight(for width: CGFloat) -> CGFloat {
        let imageAspectRatio = headerImageAspectRatio ?? fallbackHeaderImageAspectRatio
        let rawHeight = width * imageAspectRatio
        let minimumHeight = min(max(width * 0.72, 260), 320)
        let viewportHeight = bounds.height
        let maximumHeight = max(minimumHeight, min(width * 1.18, viewportHeight * 0.6))

        return min(max(rawHeight, minimumHeight), maximumHeight) + headerTopExtensionHeight
    }

    var headerTopExtensionHeight: CGFloat {
        guard imageHeaderUsesBackgroundExtension else { return 0 }

        return max(safeAreaInsets.top, 0)
    }

    func updateHeaderContentPlacement(topExtensionHeight: CGFloat = 0) {
        guard imageContentTopAnchor != nil else { return }

        if abs(imageContentTopAnchor.constant - topExtensionHeight) > 0.5 {
            imageContentTopAnchor.constant = topExtensionHeight
        }

        if let backgroundExtensionContentTopAnchor,
           abs(backgroundExtensionContentTopAnchor.constant - topExtensionHeight) > 0.5 {
            backgroundExtensionContentTopAnchor.constant = topExtensionHeight
        }
    }

    func updateNoHeaderTopSpacerHeight() {
        guard noHeaderTopSpacerHeightAnchor != nil else { return }

        let desiredHeight: CGFloat
        if noHeaderTopSpacerView.isHidden {
            desiredHeight = 0
        } else {
            desiredHeight = safeAreaInsets.top + noHeaderNavigationSpacing
        }

        guard abs(noHeaderTopSpacerHeightAnchor.constant - desiredHeight) > 0.5 else { return }

        noHeaderTopSpacerHeightAnchor.constant = desiredHeight
    }

    func makeInfoRow(systemImageName: String, title: String, valueLabel: UILabel) -> UIView {
        let rowView = UIView()
        #if os(tvOS)
        rowView.backgroundColor = ApplicationTheme.current.cardBackgroundColor
        #else
        rowView.backgroundColor = .systemGray6
        #endif
        rowView.layer.cornerRadius = 14
        rowView.layer.cornerCurve = .continuous
        rowView.layer.borderWidth = 1
        rowView.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        rowView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: systemImageName))
        imageView.tintColor = .secondaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(for: .caption1, weight: .semibold, compatibleWith: .current)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .tertiaryLabel

        valueLabel.font = .preferredFont(for: .subheadline, weight: .semibold, compatibleWith: .current)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        rowView.addSubview(imageView)
        rowView.addSubview(textStack)

        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),

            imageView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: eventDetailMargin),
            imageView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -eventDetailMargin),
            textStack.topAnchor.constraint(equalTo: rowView.topAnchor, constant: 9),
            textStack.bottomAnchor.constraint(equalTo: rowView.bottomAnchor, constant: -9),
        ])

        return rowView
    }

    func makeInsetContainer(_ containedView: UIView) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(containedView)

        // Activate viewport anchors after this container joins the scroll hierarchy.
        contentWidthConstraints.append(contentsOf: [
            containedView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: contentHorizontalInset),
            containedView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -contentHorizontalInset),
        ])
        NSLayoutConstraint.activate([
            containedView.topAnchor.constraint(equalTo: containerView.topAnchor),
            containedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        return containerView
    }

    func configureMetadata(for event: Event?) {
        scheduleValueLabel.text = scheduleText(for: event)
        locationValueLabel.text = locationText(for: event)
        organizerValueLabel.text = organizerText(for: event)

        scheduleInfoView.isHidden = viewModel.config?.showsFestivalSubtitle == true || scheduleValueLabel.text == nil
        locationInfoView.isHidden = viewModel.config?.showsFestivalSubtitle == true || locationValueLabel.text == nil
        organizerInfoView.isHidden = organizerValueLabel.text == nil
        metadataContainerView.isHidden = [scheduleInfoView, locationInfoView, organizerInfoView].allSatisfy(\.isHidden)
    }

    func scheduleText(for event: Event?) -> String? {
        event.flatMap { EventPresentation.dateRange(for: $0) }
    }

    func locationText(for event: Event?) -> String? {
        event.flatMap { EventPresentation.location(for: $0) }
    }

    func organizerText(for event: Event?) -> String? {
        guard let event else { return nil }

        let organizer = event.organisationName ?? event.extras?.organizer
        guard let organizer, !organizer.isEmpty else { return nil }

        return organizer
    }

    func configureImage(url: URL?) {
        imageTask?.cancel()
        imageView.image = nil
        backgroundExtensionImageView.image = nil
        #if os(tvOS)
        let placeholderColor = ApplicationTheme.current.cardBackgroundColor
        #else
        let placeholderColor = UIColor.secondarySystemFill
        #endif
        imageView.backgroundColor = placeholderColor
        backgroundExtensionImageView.backgroundColor = placeholderColor
        headerImageAspectRatio = nil
        updateHeaderHeight(force: true)

        guard let url else {
            imageView.backgroundColor = .clear
            backgroundExtensionImageView.backgroundColor = .clear
            resetStretchyHeader()
            return
        }

        imageTask = ImagePipeline.shared.loadImage(with: url) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let response):
                    self.imageView.image = response.image
                    self.backgroundExtensionImageView.image = response.image
                    self.imageView.backgroundColor = ApplicationTheme.current.cardBackgroundColor
                    self.backgroundExtensionImageView.backgroundColor = ApplicationTheme.current.cardBackgroundColor
                    self.headerImageAspectRatio = self.headerAspectRatio(for: response.image)
                    self.updateHeaderHeight(force: true)
                    self.updateStretchyHeader(for: self.scrollView.contentOffset.y)
                case .failure:
                    self.imageView.image = nil
                    self.backgroundExtensionImageView.image = nil
                    #if os(tvOS)
                    let failureColor = ApplicationTheme.current.cardBackgroundColor
                    #else
                    let failureColor = UIColor.tertiarySystemFill
                    #endif
                    self.imageView.backgroundColor = failureColor
                    self.backgroundExtensionImageView.backgroundColor = failureColor
                    self.headerImageAspectRatio = nil
                    self.updateHeaderHeight(force: true)
                }
            }
        }
    }

    func headerAspectRatio(for image: UIImage) -> CGFloat? {
        guard image.size.width > 0, image.size.height > 0 else {
            return nil
        }

        return image.size.height / image.size.width
    }

    func updateStretchyHeader(for offsetY: CGFloat) {
        let offsetY = offsetY + scrollView.adjustedContentInset.top
        guard !imageHeaderUsesBackgroundExtension else {
            resetStretchyHeader()
            return
        }

        guard hasStretchyHeader, !imageHeaderView.isHidden else {
            resetStretchyHeader()
            return
        }

        guard offsetY < 0, imageHeaderView.bounds.height > 0 else {
            resetStretchyHeader()
            return
        }

        let stretchDistance = -offsetY
        let scale = 1 + (stretchDistance / imageHeaderView.bounds.height)

        imageHeaderView.transform = CGAffineTransform(translationX: 0, y: offsetY / 2)
            .scaledBy(x: scale, y: scale)
    }

    func resetStretchyHeader() {
        guard imageHeaderView.transform != .identity else { return }

        imageHeaderView.transform = .identity
    }

}

extension EventDetailView {

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateStretchyHeader(for: scrollView.contentOffset.y)
    }

}
