//
//  NewMapViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.03.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import UIKit
import MapKit
import Core
import MMEvents
import Factory
import Combine
import OSLog

public class NewMapViewController: UIViewController {
    
    // MARK: - Properties
    
    @LazyInjected(\.placeRepository) var placeRepository
    @LazyInjected(\.locationEventService) var locationService
    
    public var coordinator: EventCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "moers-festival", category: "NewMapViewController")
    
    private lazy var mapView: FestivalMapView = {
        let map = FestivalMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        map.mapType = .mutedStandard
        map.showsUserLocation = true
        map.showsCompass = false
        map.accessibilityIdentifier = "FestivalMap"
        return map
    }()
    
    private var drawerViewController: NewMapDrawerViewController?
    private var overlayPanelController: MapPanelContainerController?
    private var sheetTransitioningDelegate: TabSheetTransitioningDelegate?
    private var currentFeatures: [StylableFeature] = []
    private var festivalGeoData: FGDCollection?
    
    private var usesOverlayPanels: Bool {
        traitCollection.userInterfaceIdiom == .pad
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupMap()
        setupListeners()
        configureMapDrawerIfNeeded()

        loadTask = Task { [weak self] in
            guard let self else { return }
            await loadFestivalDataFromDisk()
            await locationService.updateLocalFestivalArchive(force: false)
            await loadFestivalDataFromDisk()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        if usesOverlayPanels {
            configureMapDrawerIfNeeded()
        } else {
            presentDrawer()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveUpdateGeoData),
            name: .updateFestivalGeoData,
            object: nil
        )
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .updateFestivalGeoData, object: nil)
    }

    deinit {
        loadTask?.cancel()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayPanelController?.invalidatePanelLayout(animated: false)
    }

    @objc private func receiveUpdateGeoData() {
        Task { [weak self] in await self?.loadFestivalDataFromDisk() }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupMap() {
        
        let center = CLLocationCoordinate2D(
            latitude: 51.44974,
            longitude: 6.62472
        )
        
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.0068973157154204046, longitudeDelta: 0.009139409120026976)
        )
        
        mapView.setRegion(region, animated: false)
        
        mapView.setCamera(
            MKMapCamera(
                lookingAtCenter: CLLocationCoordinate2D(
                    latitude: 51.44974,
                    longitude: 6.62472
                ),
                fromDistance: 1211,
                pitch: 0,
                heading: 341
            ),
            animated: false
        )
        
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
        
    }
    
    private func setupListeners() {
        
        placeRepository.changeObserver()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] places in
                guard let self = self else { return }
                
                let existingVenueAnnotations = self.mapView.annotations.filter { $0 is VenueAnnotation }
                self.mapView.removeAnnotations(existingVenueAnnotations)
                
                let venueAnnotations = places.map { place in
                    VenueAnnotation(
                        title: place.name,
                        coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng),
                        placeID: place.id
                    )
                }
                
                self.mapView.addAnnotations(venueAnnotations)
            }
            .store(in: &cancellables)
    }
    
    private func configureMapDrawerIfNeeded() {
        
        guard usesOverlayPanels else { return }
        guard overlayPanelController == nil else { return }
        
        let drawer = NewMapDrawerViewController()
        drawer.delegate = self
        drawer.setExpandedContentVisible(isVisible: false, animated: false)
        drawer.setCollectionViewScrollInteraction(isEnabled: false)
        drawerViewController = drawer
        
        let overlayController = MapPanelContainerController()
        overlayController.topBoundaryProvider = { [weak self] in
            self?.panelTopBoundary() ?? 16
        }
        overlayController.onBaseStateChange = { [weak self] state in
            guard let self else { return }
            let isExpanded = state == .expanded
            self.drawerViewController?.setExpandedContentVisible(isVisible: isExpanded, animated: true)
            self.drawerViewController?.setCollectionViewScrollInteraction(isEnabled: isExpanded)
            if !isExpanded {
                self.drawerViewController?.resignSearch()
            }
        }
        
        addChild(overlayController)
        overlayController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayController.view)
        NSLayoutConstraint.activate([
            overlayController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayController.view.topAnchor.constraint(equalTo: view.topAnchor),
            overlayController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        overlayController.didMove(toParent: self)
        overlayController.installBasePanel(with: drawer, initialState: .peek)
        overlayController.invalidatePanelLayout(animated: false)
        
        if let dorf = festivalGeoData?.dorf {
            drawer.updateBooths(dorf)
        }
        
        overlayPanelController = overlayController
    }
    
    private func panelTopBoundary() -> CGFloat {
        
        var topBoundary = view.safeAreaInsets.top
        
        if let tabBar = tabBarController?.tabBar,
           let tabBarSuperview = tabBar.superview {
            let tabBarFrame = view.convert(tabBar.frame, from: tabBarSuperview)
            topBoundary = max(topBoundary, tabBarFrame.maxY)
        }
        
        return topBoundary + 16
    }

    // MARK: - Data Loading

    @MainActor
    private func loadFestivalDataFromDisk() async {
        guard let directory = LocalFGDStore.directory() else { return }
        do {
            let collection = try FGDArchiveDecoder().decode(directory)
            applyFestivalData(collection)
        } catch {
            logger.error("Failed to decode festival geo data: \(error)")
        }
    }

    @MainActor
    private func applyFestivalData(_ collection: FGDCollection) {
        festivalGeoData = collection
        currentFeatures = []
        currentFeatures.append(contentsOf: collection.surfaces)
        currentFeatures.append(contentsOf: collection.stages)
        currentFeatures.append(contentsOf: collection.camping)
        currentFeatures.append(contentsOf: collection.transporation)
        currentFeatures.append(contentsOf: collection.dorf)
        currentFeatures.append(contentsOf: collection.medicalService)
        currentFeatures.append(contentsOf: collection.toilets)
        currentFeatures.append(contentsOf: collection.tickets)
        addOverlays()
        showAnnotationsIfNeeded()
        drawerViewController?.updateBooths(collection.dorf)
    }
    
    private func addOverlays() {
        
        mapView.removeOverlays(mapView.overlays)
        
        let currentGeometry = currentFeatures.flatMap { $0.geometry }
        let currentOverlays = currentGeometry.compactMap { $0 as? MKOverlay }
        
        mapView.addOverlays(currentOverlays)
    }
    
    private func showAnnotationsIfNeeded() {
        
        addAnnotationsIfNeeded(festivalGeoData?.dorf, threshold: DorfAnnotation.mapScaleThreshold)
        addAnnotationsIfNeeded(festivalGeoData?.toilets, threshold: ToiletAnnotation.mapScaleThreshold)
        addAnnotationsIfNeeded(festivalGeoData?.medicalService, threshold: MedicalServiceAnnotation.mapScaleThreshold)
        addAnnotationsIfNeeded(festivalGeoData?.transporation, threshold: BikeAnnotation.mapScaleThreshold)
        addAnnotationsIfNeeded(festivalGeoData?.tickets, threshold: TicketAnnotation.mapScaleThreshold)
    }
    
    private func addAnnotationsIfNeeded(_ features: [DorfFeature]?, threshold: Double) {
        
        let scale = mapView.region.span.latitudeDelta
        
        if scale <= threshold {
            
            if let features = features {
                let annotations = features.map { $0.toAnnotation() }
                mapView.addAnnotations(annotations)
            }
            
        }
    }
    
    private func addAnnotationsIfNeeded(_ features: [ToiletFeature]?, threshold: Double) {
        
        let scale = mapView.region.span.latitudeDelta
        
        if scale <= threshold {
            
            if let features = features {
                let annotations = features.map { $0.toAnnotation() }
                mapView.addAnnotations(annotations)
            }
            
        }
    }
    
    private func addAnnotationsIfNeeded(_ features: [MedicalServiceFeature]?, threshold: Double) {
        
        let scale = mapView.region.span.latitudeDelta
        
        if scale <= threshold {
            
            if let features = features {
                let annotations = features.map { $0.toAnnotation() }
                mapView.addAnnotations(annotations)
            }
            
        }
    }
    
    private func addAnnotationsIfNeeded(_ features: [TransportationFeature]?, threshold: Double) {
        
        let scale = mapView.region.span.latitudeDelta
        
        if scale <= threshold {
            
            if let features = features {
                let annotations = features.map { $0.toAnnotation() }
                mapView.addAnnotations(annotations)
            }
            
        }
    }
    
    private func addAnnotationsIfNeeded(_ features: [TicketFeature]?, threshold: Double) {
        
        let scale = mapView.region.span.latitudeDelta
        
        if scale <= threshold {
            
            if let features = features {
                let annotations = features.map { $0.toAnnotation() }
                mapView.addAnnotations(annotations)
            }
            
        }
    }
    
    // MARK: - Sheet Presentation
    
    private func presentDrawer() {
        
        guard !usesOverlayPanels else {
            configureMapDrawerIfNeeded()
            return
        }
        
        if let drawerViewController, presentedViewController === drawerViewController {
            return
        }
        
        let drawer = NewMapDrawerViewController()
        drawer.delegate = self
        
        self.drawerViewController = drawer
        
        let transitionDelegate = TabSheetTransitioningDelegate()
        transitionDelegate.sheetDelegate = self
        self.sheetTransitioningDelegate = transitionDelegate
        
        drawer.isModalInPresentation = true
        drawer.modalPresentationStyle = .custom
        drawer.transitioningDelegate = transitionDelegate
        
        self.present(drawer, animated: false)

    }
    
    // MARK: - Public Methods
    
    private func showPlaceDetail(placeID: Place.ID) {
        
        if usesOverlayPanels {
            configureMapDrawerIfNeeded()
            drawerViewController?.resignSearch()
            
            let viewController = VenueDetailController(placeID: placeID, presentationContext: .ipadDetail)
            viewController.coordinator = coordinator
            
            overlayPanelController?.showDetailPanel(with: viewController, animated: true)
            return
        }
        
        let viewController = VenueDetailController(placeID: placeID, presentationContext: .phoneFullScreen)
        viewController.coordinator = coordinator
        viewController.modalPresentationStyle = .formSheet
        viewController.showCloseButton = true
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        
        if let presenter = (presentedViewController as? NewMapDrawerViewController) ?? drawerViewController {
            presenter.present(navController, animated: true)
        } else {
            present(navController, animated: true)
        }
    }
    
    func focusOnFeature(_ feature: DorfFeature) {
        
        let camera = MKMapCamera(
            lookingAtCenter: feature.toAnnotation().coordinate,
            fromDistance: 50,
            pitch: 0,
            heading: 0
        )
        
        mapView.setCamera(camera, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let annotation = self.mapView.annotations.first(where: {
                guard let featureAnnotation = $0 as? DorfAnnotation else { return false }
                return featureAnnotation.coordinate == feature.toAnnotation().coordinate
            }) {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .dark {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
}

// MARK: - MKMapViewDelegate

extension NewMapViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let shape = overlay as? (MKShape & MKGeoJSONObject),
              let feature = currentFeatures.first(where: { $0.geometry.contains(where: { $0 == shape }) }) else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let renderer: MKOverlayPathRenderer
        
        switch overlay {
        case is MKMultiPolygon:
            renderer = MKMultiPolygonRenderer(overlay: overlay)
        case is MKPolygon:
            renderer = MKPolygonRenderer(overlay: overlay)
        case is MKMultiPolyline:
            renderer = MKMultiPolylineRenderer(overlay: overlay)
        case is MKPolyline:
            renderer = MKPolylineRenderer(overlay: overlay)
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
        
        feature.configure(overlayRenderer: renderer)
        
        return renderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        if let venueAnnotation = annotation as? VenueAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "venueAnnotation") as? VenueAnnotationView
            
            if view == nil {
                view = VenueAnnotationView(annotation: venueAnnotation, reuseIdentifier: "venueAnnotation")
            }
            
            view?.annotation = venueAnnotation
            
            return view
        } else if let dorfAnnotation = annotation as? DorfAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "dorfAnnotation") as? DorfAnnotationView
            
            if view == nil {
                view = DorfAnnotationView(annotation: annotation, reuseIdentifier: "dorfAnnotation")
            }
            
            view?.annotation = dorfAnnotation
            
            return view
        } else if let toiletAnnotation = annotation as? ToiletAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "toiletAnnotation") as? ToiletAnnotationView
            
            if view == nil {
                view = ToiletAnnotationView(annotation: annotation, reuseIdentifier: "toiletAnnotation")
            }
            
            view?.annotation = toiletAnnotation
            
            return view
        } else if let medicalAnnotation = annotation as? MedicalServiceAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "medicalServiceAnnotation") as? MedicalServiceAnnotationView
            
            if view == nil {
                view = MedicalServiceAnnotationView(annotation: annotation, reuseIdentifier: "medicalServiceAnnotation")
            }
            
            view?.annotation = medicalAnnotation
            
            return view
        } else if let bikeAnnotation = annotation as? BikeAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "bikeAnnotation") as? BikeAnnotationView
            
            if view == nil {
                view = BikeAnnotationView(annotation: annotation, reuseIdentifier: "bikeAnnotation")
            }
            
            view?.annotation = bikeAnnotation
            
            return view
        } else if let ticketAnnotation = annotation as? TicketAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "ticketAnnotation") as? TicketAnnotationView
            
            if view == nil {
                view = TicketAnnotationView(annotation: annotation, reuseIdentifier: "ticketAnnotation")
            }
            
            view?.annotation = ticketAnnotation
            
            return view
        }
        
        return nil
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        mapView.removeAnnotations(
            mapView.annotations.filter {
                !($0 is MKUserLocation) && !($0 is VenueAnnotation)
            }
        )
        
        showAnnotationsIfNeeded()
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let venueAnnotation = view.annotation as? VenueAnnotation {
            showPlaceDetail(placeID: venueAnnotation.placeID)
        }
    }
}

// MARK: - UISheetPresentationControllerDelegate

extension NewMapViewController: UISheetPresentationControllerDelegate {
    
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        
        guard !usesOverlayPanels else { return }
        
        if sheetPresentationController.selectedDetentIdentifier == .nearFull {
            drawerViewController?.setCollectionViewScrollInteraction(isEnabled: true)
        } else {
            drawerViewController?.setCollectionViewScrollInteraction(isEnabled: false)
        }
        
        drawerViewController?.searchBar.resignFirstResponder()
        
    }
    
}

// MARK: - NewMapDrawerDelegate

extension NewMapViewController: NewMapDrawerDelegate {
    
    func drawerDidSelectBooth(_ booth: DorfFeature) {
        
        if usesOverlayPanels {
            overlayPanelController?.setBasePanelState(.peek, animated: true)
            drawerViewController?.resignSearch()
            focusOnFeature(booth)
            return
        }

        if let sheet = drawerViewController?.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .small
            }
        }

        focusOnFeature(booth)
    }

    func drawerDidSelectVenue(_ venue: FestivalPlaceRowUi) {
        
        if usesOverlayPanels {
            drawerViewController?.resignSearch()
            showPlaceDetail(placeID: venue.id)
            return
        }

        if let sheet = drawerViewController?.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .small
            }
        }
        
        showPlaceDetail(placeID: venue.id)
    }
    
    func drawerDidBeginSearch() {
        
        if usesOverlayPanels {
            overlayPanelController?.setBasePanelState(.expanded, animated: true)
            return
        }
        
        if let sheet = drawerViewController?.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .nearFull
            }
        }
    }
}

private enum MapPanelState {
    case peek
    case expanded
}

private final class MapPanelContainerController: UIViewController {
    
    var topBoundaryProvider: (() -> CGFloat)?
    var onBaseStateChange: ((MapPanelState) -> Void)?
    
    private let panelInset: CGFloat = 16
    private let preferredPanelWidth: CGFloat = 380
    private let peekHeight: CGFloat = 96
    private let baseChromeHeight: CGFloat = 24
    private let detailChromeHeight: CGFloat = 56
    
    private let panelView = UIView()
    private let materialView = UIVisualEffectView()
    private let tintView = UIView()
    private let chromeView = UIView()
    private let grabberView = UIView()
    private let closeButton = UIButton(type: .system)
    private let contentContainerView = UIView()
    
    private var panelWidthConstraint: NSLayoutConstraint!
    private var panelHeightConstraint: NSLayoutConstraint!
    private var chromeHeightConstraint: NSLayoutConstraint!
    
    private var baseController: UIViewController?
    private var detailController: UIViewController?
    private(set) var baseState: MapPanelState = .peek
    private var storedBaseState: MapPanelState = .peek
    private var panStartingHeight: CGFloat = 0
    
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanelPan(_:)))
    
    override func loadView() {
        view = MapPanelPassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        applyBaseChrome()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updatePanelAppearance()
    }
    
    func installBasePanel(with controller: UIViewController, initialState: MapPanelState) {
        
        guard baseController == nil else { return }
        
        baseController = controller
        embed(controller, in: contentContainerView)
        controller.view.backgroundColor = .clear
        storedBaseState = initialState
        setBasePanelState(initialState, animated: false)
    }
    
    func setBasePanelState(_ state: MapPanelState, animated: Bool) {
        
        baseState = state
        storedBaseState = state
        onBaseStateChange?(state)
        
        guard detailController == nil else { return }
        
        applyBaseChrome()
        invalidatePanelLayout(animated: animated)
    }
    
    func showDetailPanel(with controller: UIViewController, animated: Bool) {
        
        if let existingDetail = detailController {
            remove(existingDetail)
        }
        
        if detailController == nil {
            storedBaseState = baseState
        }
        
        detailController = controller
        controller.view.backgroundColor = .clear
        baseController?.view.isHidden = true
        embed(controller, in: contentContainerView)
        applyDetailChrome()
        invalidatePanelLayout(animated: animated)
        
        guard animated else { return }
        
        controller.view.alpha = 0
        controller.view.transform = CGAffineTransform(translationX: 0, y: 32)
        
        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseOut]) {
            controller.view.alpha = 1
            controller.view.transform = .identity
        }
    }
    
    func invalidatePanelLayout(animated: Bool) {
        
        let availableWidth = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - (panelInset * 2)
        panelWidthConstraint.constant = min(preferredPanelWidth, max(280, availableWidth))
        
        if detailController != nil {
            panelHeightConstraint.constant = expandedHeight()
            chromeHeightConstraint.constant = detailChromeHeight
        } else {
            panelHeightConstraint.constant = baseState == .peek ? peekHeight : expandedHeight()
            chromeHeightConstraint.constant = baseChromeHeight
        }
        
        let animations = {
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [.curveEaseInOut], animations: animations)
        } else {
            animations()
        }
    }
    
    private func setupUI() {
        
        view.backgroundColor = .clear
        
        panelView.translatesAutoresizingMaskIntoConstraints = false
        panelView.layer.cornerRadius = 28
        panelView.layer.cornerCurve = .continuous
        panelView.layer.borderWidth = 1 / UIScreen.main.scale
        panelView.layer.shadowRadius = 24
        panelView.layer.shadowOffset = CGSize(width: 0, height: 12)
        panelView.clipsToBounds = true
        
        materialView.translatesAutoresizingMaskIntoConstraints = false
        
        tintView.translatesAutoresizingMaskIntoConstraints = false
        
        chromeView.translatesAutoresizingMaskIntoConstraints = false
        chromeView.backgroundColor = .clear
        chromeView.addGestureRecognizer(panGestureRecognizer)
        
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        grabberView.layer.cornerRadius = 2.5
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.layer.cornerRadius = 20
        closeButton.layer.cornerCurve = .continuous
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeDetailPanel), for: .touchUpInside)
        
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.backgroundColor = .clear
        
        view.addSubview(panelView)
        panelView.addSubview(materialView)
        panelView.addSubview(tintView)
        panelView.addSubview(chromeView)
        panelView.addSubview(contentContainerView)
        chromeView.addSubview(grabberView)
        chromeView.addSubview(closeButton)
        
        (view as? MapPanelPassthroughView)?.trackedView = panelView
        
        updatePanelAppearance()
    }
    
    private func setupConstraints() {
        
        panelWidthConstraint = panelView.widthAnchor.constraint(equalToConstant: preferredPanelWidth)
        panelHeightConstraint = panelView.heightAnchor.constraint(equalToConstant: peekHeight)
        chromeHeightConstraint = chromeView.heightAnchor.constraint(equalToConstant: baseChromeHeight)
        
        NSLayoutConstraint.activate([
            panelView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: panelInset),
            panelView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -panelInset),
            panelWidthConstraint,
            panelHeightConstraint,
            
            materialView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            materialView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            materialView.topAnchor.constraint(equalTo: panelView.topAnchor),
            materialView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            
            tintView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            tintView.topAnchor.constraint(equalTo: panelView.topAnchor),
            tintView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            
            chromeView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            chromeView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            chromeView.topAnchor.constraint(equalTo: panelView.topAnchor),
            chromeHeightConstraint,
            
            contentContainerView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: chromeView.bottomAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            
            grabberView.centerXAnchor.constraint(equalTo: chromeView.centerXAnchor),
            grabberView.topAnchor.constraint(equalTo: chromeView.topAnchor, constant: 8),
            grabberView.widthAnchor.constraint(equalToConstant: 48),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            closeButton.trailingAnchor.constraint(equalTo: chromeView.trailingAnchor, constant: -12),
            closeButton.topAnchor.constraint(equalTo: chromeView.topAnchor, constant: 12),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func applyBaseChrome() {
        grabberView.isHidden = false
        closeButton.isHidden = true
        panGestureRecognizer.isEnabled = true
    }
    
    private func applyDetailChrome() {
        grabberView.isHidden = true
        closeButton.isHidden = false
        panGestureRecognizer.isEnabled = false
    }
    
    private func updatePanelAppearance() {
        
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        materialView.effect = UIBlurEffect(style: isDarkMode ? .systemThinMaterialDark : .systemChromeMaterialLight)
        
        panelView.layer.borderColor = (isDarkMode
            ? UIColor.white.withAlphaComponent(0.14)
            : UIColor.black.withAlphaComponent(0.08)
        ).cgColor
        
        panelView.layer.shadowColor = UIColor.black.cgColor
        panelView.layer.shadowOpacity = isDarkMode ? 0.22 : 0.10
        
        tintView.backgroundColor = isDarkMode
            ? UIColor.secondarySystemBackground.withAlphaComponent(0.14)
            : UIColor.white.withAlphaComponent(0.05)
        
        grabberView.backgroundColor = isDarkMode
            ? UIColor.white.withAlphaComponent(0.35)
            : UIColor.secondaryLabel.withAlphaComponent(0.28)
        
        closeButton.tintColor = isDarkMode ? .white : .label
        closeButton.backgroundColor = isDarkMode
            ? UIColor.black.withAlphaComponent(0.22)
            : UIColor.systemBackground.withAlphaComponent(0.72)
    }
    
    private func expandedHeight() -> CGFloat {
        
        let topBoundary = max(topBoundaryProvider?() ?? 16, view.safeAreaInsets.top + 16)
        let safeAreaBottom = view.safeAreaInsets.bottom
        let availableHeight = view.bounds.height - safeAreaBottom - panelInset - topBoundary
        
        return max(peekHeight, availableHeight)
    }
    
    private func embed(_ child: UIViewController, in containerView: UIView) {
        
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        child.didMove(toParent: self)
    }
    
    private func remove(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    @objc
    private func closeDetailPanel() {
        
        guard let detailController else { return }
        
        self.detailController = nil
        baseState = storedBaseState
        onBaseStateChange?(storedBaseState)
        baseController?.view.isHidden = false
        applyBaseChrome()
        invalidatePanelLayout(animated: true)
        
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
            detailController.view.alpha = 0
            detailController.view.transform = CGAffineTransform(translationX: 0, y: 32)
        } completion: { _ in
            detailController.view.transform = .identity
            self.remove(detailController)
        }
    }
    
    @objc
    private func handlePanelPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard detailController == nil else { return }
        
        let maxHeight = expandedHeight()
        
        switch gestureRecognizer.state {
        case .began:
            panStartingHeight = panelHeightConstraint.constant
            
        case .changed:
            let translation = gestureRecognizer.translation(in: view).y
            let nextHeight = panStartingHeight - translation
            panelHeightConstraint.constant = min(max(nextHeight, peekHeight), maxHeight)
            view.layoutIfNeeded()
            
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: view).y
            let midpoint = (peekHeight + maxHeight) / 2
            let nextState: MapPanelState
            
            if abs(velocity) > 300 {
                nextState = velocity < 0 ? .expanded : .peek
            } else {
                nextState = panelHeightConstraint.constant > midpoint ? .expanded : .peek
            }
            
            setBasePanelState(nextState, animated: true)
            
        default:
            break
        }
    }
}

private final class MapPanelPassthroughView: UIView {
    
    weak var trackedView: UIView?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let trackedView else { return false }
        let convertedPoint = convert(point, to: trackedView)
        return trackedView.point(inside: convertedPoint, with: event)
    }
}
