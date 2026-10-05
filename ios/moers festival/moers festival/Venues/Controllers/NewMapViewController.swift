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
import FactoryKit
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
    private var venueDetailNavigationController: UINavigationController?
    private var pendingVenueID: Place.ID?
    private var drawerDetent: UISheetPresentationController.Detent.Identifier = .small
    private var drawerTransitionIsInProgress = false
    private var wantsDrawerVisible = false
    private var wasHiddenByTabSelection = false
    private var suspensionCompletions: [() -> Void] = []
    private var currentFeatures: [StylableFeature] = []
    private var festivalGeoData: FGDCollection?
    
    private var usesOverlayPanels: Bool {
        traitCollection.horizontalSizeClass == .regular
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true

        setupUI()
        setupConstraints()
        setupMap()
        setupListeners()
        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: NewMapViewController, _) in
            self.updateDrawerPresentation()
        }

        loadTask = Task { [weak self] in
            guard let self else { return }
            await loadFestivalDataFromDisk()
            await locationService.updateLocalFestivalArchive(force: false)
            await loadFestivalDataFromDisk()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        if wasHiddenByTabSelection || !drawerTransitionIsInProgress {
            wasHiddenByTabSelection = false
            resumeDrawerPresentation()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveUpdateGeoData),
            name: .updateFestivalGeoData,
            object: nil
        )
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDrawerPresentation()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let tabBarController, tabBarController.selectedViewController !== self {
            wasHiddenByTabSelection = true
            suspendDrawerPresentation()
        }
        NotificationCenter.default.removeObserver(self, name: .updateFestivalGeoData, object: nil)
    }

    deinit {
        loadTask?.cancel()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayPanelController?.invalidatePanelLayout(animated: false)
        updateDrawerPresentation()
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
            latitude: 51.45020,
            longitude: 6.62546
        )
        
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.0068973157154204046, longitudeDelta: 0.009139409120026976)
        )
        
        mapView.setRegion(region, animated: false)
        
        mapView.setCamera(
            MKMapCamera(
                lookingAtCenter: center,
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

extension NewMapViewController {

    private func ensureDrawer() -> NewMapDrawerViewController {
        if let drawerViewController { return drawerViewController }
        let drawer = NewMapDrawerViewController()
        drawer.delegate = self
        drawer.onDidAppear = { [weak self] in self?.updateDrawerPresentation() }
        if let dorf = festivalGeoData?.dorf {
            drawer.updateBooths(dorf)
        }
        drawerViewController = drawer
        return drawer
    }

    private func installOverlayPanels(with drawer: NewMapDrawerViewController) {
        let overlay = MapPanelContainerController()
        overlay.topBoundaryProvider = { [weak self] in
            (self?.view.safeAreaInsets.top ?? 0) + 16
        }
        overlay.onBaseStateChange = { [weak self] state in
            guard let self else { return }
            let previousState: MapPanelState = self.drawerDetent == .small ? .peek : .expanded
            if state != previousState {
                self.drawerDetent = state == .peek ? .small : .nearFull
            }
            let isExpanded = state == .expanded
            drawer.setExpandedContentVisible(isVisible: isExpanded, animated: false)
            drawer.setCollectionViewScrollInteraction(isEnabled: isExpanded)
            if !isExpanded { drawer.resignSearch() }
        }
        overlay.onDetailClose = { [weak self] in self?.venueDetailNavigationController = nil }
        overlayPanelController = overlay
        addChild(overlay)
        overlay.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay.view)
        NSLayoutConstraint.activate([
            overlay.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.view.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        overlay.didMove(toParent: self)
        overlay.installBasePanel(with: drawer, initialState: drawerDetent == .small ? .peek : .expanded)
        if let detail = venueDetailNavigationController {
            configureVenueNavigation(forOverlay: true)
            overlay.showDetailPanel(with: detail, animated: false)
        }
        overlay.invalidatePanelLayout(animated: false)
    }

    private func removeOverlayPanels() {
        guard let overlay = overlayPanelController else { return }
        overlay.releasePanels()
        overlay.willMove(toParent: nil)
        overlay.view.removeFromSuperview()
        overlay.removeFromParent()
        overlayPanelController = nil
    }

    // MARK: - Sheet Presentation

    func resumeDrawerPresentation() {
        guard suspensionCompletions.isEmpty else { return }
        wantsDrawerVisible = true
        updateDrawerPresentation()
    }

    func suspendDrawerPresentation(completion: (() -> Void)? = nil) {
        wantsDrawerVisible = false
        saveDrawerDetent()
        if let completion { suspensionCompletions.append(completion) }
        guard !drawerTransitionIsInProgress else { return }
        if let detail = venueDetailNavigationController, detail.presentingViewController != nil {
            drawerTransitionIsInProgress = true
            detail.dismiss(animated: false) { [weak self] in self?.finishDrawerTransition() }
            return
        }
        guard let drawer = drawerViewController, drawer.presentingViewController != nil else {
            let completions = suspensionCompletions
            suspensionCompletions.removeAll()
            completions.forEach { $0() }
            return
        }
        drawerTransitionIsInProgress = true
        drawer.dismiss(animated: false) { [weak self] in
            guard let self else { return }
            self.finishDrawerTransition()
        }
    }

    private func finishDrawerTransition() {
        drawerTransitionIsInProgress = false
        if let pendingVenueID {
            self.pendingVenueID = nil
            showPlaceDetail(placeID: pendingVenueID)
        }
        if !wantsDrawerVisible { suspendDrawerPresentation() }
        updateDrawerPresentation()
    }

    private func saveDrawerDetent() {
        if let sheet = drawerViewController?.presentationController as? UISheetPresentationController,
           let detent = sheet.selectedDetentIdentifier {
            drawerDetent = detent
        }
    }

    private func updateDrawerPresentation() {
        guard wantsDrawerVisible, isViewLoaded, view.window != nil,
              !drawerTransitionIsInProgress else { return }
        if let tabBarController, tabBarController.selectedViewController !== self { return }
        let drawer = ensureDrawer()
        let detail = venueDetailNavigationController

        guard !hasUnrelatedPresentation(drawer: drawer, detail: detail),
              !waitForPresentationTransition(drawer: drawer, detail: detail) else { return }

        if usesOverlayPanels {
            if let detail, detail.presentingViewController != nil {
                drawerTransitionIsInProgress = true
                detail.dismiss(animated: false) { [weak self] in self?.finishDrawerTransition() }
            } else if drawer.presentingViewController != nil {
                saveDrawerDetent()
                drawerTransitionIsInProgress = true
                drawer.dismiss(animated: false) { [weak self] in
                    guard let self else { return }
                    self.finishDrawerTransition()
                }
            } else if overlayPanelController == nil {
                installOverlayPanels(with: drawer)
            }
            return
        }

        presentCompactDrawerIfNeeded(drawer, detail: detail)
    }

    private func hasUnrelatedPresentation(drawer: UIViewController, detail: UINavigationController?) -> Bool {
        var ancestor: UIViewController? = self
        while let controller = ancestor {
            if let presented = controller.presentedViewController,
               presented !== drawer, presented !== detail { return true }
            ancestor = controller.parent
        }
        if detail?.presentedViewController != nil || detail?.topViewController?.presentedViewController != nil { return true }
        if let presented = drawer.presentedViewController, presented !== detail { return true }
        return false
    }

    private func waitForPresentationTransition(drawer: UIViewController, detail: UIViewController?) -> Bool {
        guard let transition = detail?.transitionCoordinator ?? drawer.transitionCoordinator,
              drawer.isBeingPresented || drawer.isBeingDismissed
                || detail?.isBeingPresented == true || detail?.isBeingDismissed == true else { return false }
        drawerTransitionIsInProgress = true
        transition.animate(alongsideTransition: nil) { [weak self] _ in
            self?.finishDrawerTransition()
        }
        return true
    }

    private func presentCompactDrawerIfNeeded(_ drawer: NewMapDrawerViewController, detail: UINavigationController?) {
        removeOverlayPanels()
        if drawer.presentingViewController == nil {
            guard presentedViewController == nil else { return }
            drawer.view.isHidden = false
            drawer.setExpandedContentVisible(isVisible: true, animated: false)
            drawer.setCollectionViewScrollInteraction(isEnabled: drawerDetent == .nearFull)
            let transitionDelegate = TabSheetTransitioningDelegate()
            transitionDelegate.sheetDelegate = self
            transitionDelegate.selectedDetentIdentifier = drawerDetent
            sheetTransitioningDelegate = transitionDelegate
            drawer.isModalInPresentation = true
            drawer.modalPresentationStyle = .custom
            drawer.transitioningDelegate = transitionDelegate
            drawerTransitionIsInProgress = true
            present(drawer, animated: false) { [weak self] in
                guard let self else { return }
                self.finishDrawerTransition()
            }
        } else if let detail, detail.presentingViewController == nil, drawer.presentedViewController == nil {
            configureVenueNavigation(forOverlay: false)
            drawerTransitionIsInProgress = true
            drawer.present(detail, animated: false) { [weak self] in
                guard let self else { return }
                detail.presentationController?.delegate = self
                self.finishDrawerTransition()
            }
        }
    }

    private func configureVenueNavigation(forOverlay: Bool) {
        guard let navigationController = venueDetailNavigationController else { return }
        navigationController.setNavigationBarHidden(forOverlay, animated: false)
        if let venue = navigationController.viewControllers.first as? VenueDetailController {
            venue.presentationContext = forOverlay ? .ipadDetail : .automatic
            venue.showCloseButton = !forOverlay
            venue.configureNavigationBar()
        }
    }

    // MARK: - Public Methods

    private func showPlaceDetail(placeID: Place.ID) {
        guard !drawerTransitionIsInProgress else {
            pendingVenueID = placeID
            return
        }
        drawerViewController?.resignSearch()
        let venue = VenueDetailController(placeID: placeID)
        venue.coordinator = coordinator
        venue.onClose = { [weak self] in self?.closePlaceDetail() }
        venue.onDidAppear = { [weak self] in self?.updateDrawerPresentation() }
        let detail = UINavigationController(rootViewController: venue)
        detail.modalPresentationStyle = .formSheet
        let existing = venueDetailNavigationController
        venueDetailNavigationController = detail
        if let existing, existing.presentingViewController != nil {
            drawerTransitionIsInProgress = true
            existing.dismiss(animated: false) { [weak self] in
                guard let self else { return }
                self.finishDrawerTransition()
            }
            return
        }
        if let overlay = overlayPanelController {
            configureVenueNavigation(forOverlay: true)
            overlay.showDetailPanel(with: detail, animated: true)
        } else {
            updateDrawerPresentation()
        }
    }

    private func closePlaceDetail() {
        guard let detail = venueDetailNavigationController else { return }
        if let overlay = overlayPanelController {
            venueDetailNavigationController = nil
            overlay.dismissDetailPanel()
        } else {
            drawerTransitionIsInProgress = true
            detail.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                if self.venueDetailNavigationController === detail {
                    self.venueDetailNavigationController = nil
                }
                self.finishDrawerTransition()
            }
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

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if presentationController.presentedViewController === venueDetailNavigationController {
            venueDetailNavigationController = nil
        }
        updateDrawerPresentation()
    }
    
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        
        guard !usesOverlayPanels,
              sheetPresentationController.presentedViewController === drawerViewController else { return }
        if let detent = sheetPresentationController.selectedDetentIdentifier {
            drawerDetent = detent
        }

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

        if let sheet = (drawerViewController?.presentationController as? UISheetPresentationController) {
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

        if let sheet = (drawerViewController?.presentationController as? UISheetPresentationController) {
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
        
        if let sheet = (drawerViewController?.presentationController as? UISheetPresentationController) {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .nearFull
            }
        }
    }
}
