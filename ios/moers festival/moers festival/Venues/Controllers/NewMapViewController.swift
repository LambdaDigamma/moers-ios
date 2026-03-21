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

public class NewMapViewController: UIViewController {
    
    // MARK: - Properties
    
    @LazyInjected(\.placeRepository) var placeRepository
    @LazyInjected(\.locationEventService) var locationService
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        map.mapType = .mutedStandard
        map.showsUserLocation = true
        map.showsCompass = false
        return map
    }()
    
    private var drawerViewController: NewMapDrawerViewController?
    private var sheetTransitioningDelegate: TabSheetTransitioningDelegate?
    private var currentFeatures: [StylableFeature] = []
    private var festivalGeoData: FGDCollection?
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupMap()
        loadFestivalData()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        presentDrawer()
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
            latitude: 51.441712626435596,
            longitude: 6.618580082309781
        )
        
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.0068973157154204046, longitudeDelta: 0.009139409120026976)
        )
        
        mapView.setRegion(region, animated: false)
        
        mapView.setCamera(
            MKMapCamera(
                lookingAtCenter: CLLocationCoordinate2D(
                    latitude: 51.44169186,
                    longitude: 6.61880121
                ),
                fromDistance: 1211,
                pitch: 0,
                heading: 341
            ),
            animated: false
        )
        
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
        
    }
    
    // MARK: - Data Loading
    
    private func loadFestivalData() {
        
        do {
            guard let directory = LocalFGDStore.directory() else { return }
            
            let festivalGeoData = try FGDArchiveDecoder().decode(directory)
            
            self.festivalGeoData = festivalGeoData
            self.currentFeatures = []
            
            currentFeatures.append(contentsOf: festivalGeoData.surfaces)
            currentFeatures.append(contentsOf: festivalGeoData.stages)
            currentFeatures.append(contentsOf: festivalGeoData.camping)
            currentFeatures.append(contentsOf: festivalGeoData.transporation)
            currentFeatures.append(contentsOf: festivalGeoData.dorf)
            currentFeatures.append(contentsOf: festivalGeoData.medicalService)
            currentFeatures.append(contentsOf: festivalGeoData.toilets)
            currentFeatures.append(contentsOf: festivalGeoData.tickets)
            
            DispatchQueue.main.async {
                self.addOverlays()
                self.showAnnotationsIfNeeded()
            }
            
        } catch {
            print("Error loading festival data: \(error)")
        }
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
        
        let drawer = NewMapDrawerViewController()
        drawer.delegate = self
        drawer.mapViewController = self
        
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
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
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
        
        if let dorfAnnotation = annotation as? DorfAnnotation {
            
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
        
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        showAnnotationsIfNeeded()
    }
}

// MARK: - UISheetPresentationControllerDelegate

extension NewMapViewController: UISheetPresentationControllerDelegate {
    
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        
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

        if let sheet = drawerViewController?.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .small
            }
        }

        focusOnFeature(booth)
    }

    func drawerDidSelectVenue(_ venue: FestivalPlaceRowUi) {

        if let sheet = drawerViewController?.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .small
            }
        }
    }
}
