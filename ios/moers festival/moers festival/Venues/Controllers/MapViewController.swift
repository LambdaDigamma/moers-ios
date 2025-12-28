//
//  MapViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 26.01.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit
import MapKit
import Pulley
import Combine
import Resolver
import MMEvents
import Factory

class MapViewController: UIViewController, PulleyPrimaryContentControllerDelegate {
    
    private var service: LocationEventService = Resolver.resolve()
    private let repository: PlaceRepository = Container.shared.placeRepository()
    
    private lazy var coordinator = { return parent as! MapCoordinatorViewController }()
    
    public lazy var map = { ViewFactory.map() }()
    private lazy var statusLabel = { ViewFactory.paddingLabel() }()
    private lazy var blur = { ViewFactory.blurView(style: .light) }()
    
    private let annotationDisplayCache: AnnotationDisplayCache = .init()
    
    private var festivalGeoData: FGDCollection? = nil
    private let gradient = CAGradientLayer()
    
    var tracker: [Tracker] = []
    
    private var currentOverlays: [MKOverlay] = []
    private var currentFeatures: [StylableFeature] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UIViewController Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupMap()
        self.setupListeners()
        
//        NotificationCenter.default.publisher(for: .updateFestivalGeoData)
//            .sink { (_: Notification) in
//                self.loadFromDiskAndPresent()
//            }
//            .store(in: &cancellables)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUpdateGeoData), name: .updateFestivalGeoData, object: nil)
        
        self.refreshOverlays()
        self.loadFromDiskAndPresent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .updateFestivalGeoData, object: nil)
    }
    
    // MARK: - Private Methods -
    
    private func setupUI() {
        
        self.title = String.localized("MapTabItem")
        
        self.view.addSubview(map)
//        self.view.addSubview(statusLabel)
        self.view.addSubview(blur)
        
        blur.overrideUserInterfaceStyle = .light
        
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.8).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.8, 1]
        gradient.frame = view.bounds
        gradient.type = .axial
        
        self.blur.layer.mask = gradient
        
        self.map.delegate = self
        
        self.map.mapType = .mutedStandard
        self.map.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            .publicTransport
//            .atm, .school, .restroom, .publicTransport, .police, .bank, .bakery, .campground, .evCharger,
//            .carRental, .gasStation, .hospital, .hotel, .parking
        ])
//        self.statusLabel.text = "\(String.localized("LastUpdate")): ✗"
//        self.statusLabel.isHidden = true
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            map.topAnchor.constraint(equalTo: self.view.topAnchor),
            map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            blur.topAnchor.constraint(equalTo: self.view.topAnchor),
            blur.bottomAnchor.constraint(equalTo: self.safeTopAnchor),
            blur.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            statusLabel.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 8),
//            statusLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
//            statusLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor { (traitCollection: UITraitCollection) in
            return traitCollection.userInterfaceStyle == .dark ? .systemBackground : .black
        }
        
        self.statusLabel.alpha = 0.25
        self.statusLabel.textColor = UIColor.black
        self.statusLabel.backgroundColor = UIColor.lightGray
        self.statusLabel.layer.cornerRadius = 4
        self.statusLabel.clipsToBounds = true
        self.statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        self.statusLabel.topInset = 4
        self.statusLabel.bottomInset = 4
//        self.statusLabel.isHidden = true
        
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
        
        map.setRegion(region, animated: false)
        map.setCamera(
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
        map.showsUserLocation = true
        map.showsCompass = false
//        map.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//        map.layer.cornerRadius = 20
//        map.layer.cornerCurve = .continuous
//        map.layer.masksToBounds = true
        map.overrideUserInterfaceStyle = .light
        map.tintColor = UIColor.systemBlue
        
    }
    
    private func refreshOverlays() {
        
        Task {
            
            await service.updateLocalFestivalArchive(force: false)
            
//            self.loadFromDiskAndPresent()
            
        }
        
    }
    
    private func loadFromDiskAndPresent() {
        
        do {
            
            guard let directory = LocalFGDStore.directory() else { return }
            
            let festivalGeoData = try FGDArchiveDecoder().decode(directory)
            
            currentFeatures.append(contentsOf: festivalGeoData.surfaces)
            currentFeatures.append(contentsOf: festivalGeoData.stages)
            currentFeatures.append(contentsOf: festivalGeoData.camping)
            currentFeatures.append(contentsOf: festivalGeoData.transporation)
            
            currentFeatures.append(contentsOf: festivalGeoData.dorf)
            currentFeatures.append(contentsOf: festivalGeoData.medicalService)
            currentFeatures.append(contentsOf: festivalGeoData.toilets)
            currentFeatures.append(contentsOf: festivalGeoData.tickets)
            
            self.festivalGeoData = festivalGeoData
            
            DispatchQueue.main.async {
                
                self.map.removeOverlays(self.map.overlays)
                
                let currentGeometry = self.currentFeatures.flatMap({ $0.geometry })
                self.currentOverlays = currentGeometry.compactMap({ $0 as? MKOverlay })
                
                self.map.addOverlays(self.currentOverlays)
                
                self.annotationDisplayCache.setShowingAnnotations(false, for: ToiletAnnotation.displayCacheKey)
                self.annotationDisplayCache.setShowingAnnotations(false, for: BikeAnnotation.displayCacheKey)
                self.annotationDisplayCache.setShowingAnnotations(false, for: DorfAnnotation.displayCacheKey)
                self.annotationDisplayCache.setShowingAnnotations(false, for: MedicalServiceAnnotation.displayCacheKey)
                self.annotationDisplayCache.setShowingAnnotations(false, for: TicketAnnotation.displayCacheKey)
                
                self.showAnnotationsIfNeeded()
                
            }
            
        } catch {
            print(error)
        }
        
    }
    
    @objc private func receiveUpdateGeoData() {
        
        self.loadFromDiskAndPresent()
        
    }
    
    // MARK: - Public Methods
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    // MARK: - Map Handling -
    
    public func removeAnnotations(ofType annotationType: MKAnnotation.Type) {
        
        let annotationsToRemove = map.annotations.filter { (annotation: MKAnnotation) in
//
//            print("type: ")
//            print(type(of: annotation))
//            print(annotationType)
//
            if type(of: annotation) == annotationType {
                return true
            } else {
                return false
            }
            
        }
        
        print("remove annotations of type \(annotationType)")
        print(annotationsToRemove)
        
        self.map.removeAnnotations(annotationsToRemove)
        
    }
    
    private func showToiletsIfNeeded() {
        
        let scale = self.map.region.span.latitudeDelta
        
        if scale <= ToiletAnnotation.mapScaleThreshold {
            
            if !annotationDisplayCache.isShowingAnnotations(for: ToiletAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: ToiletAnnotation.self)
                self.map.addAnnotations(festivalGeoData?.toilets.map { $0.toAnnotation() } ?? [])
                self.annotationDisplayCache.setShowingAnnotations(true, for: ToiletAnnotation.displayCacheKey)
            }
            
        } else {
            
            if annotationDisplayCache.isShowingAnnotations(for: ToiletAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: ToiletAnnotation.self)
                self.annotationDisplayCache.setShowingAnnotations(false, for: ToiletAnnotation.displayCacheKey)
            }
            
        }
        
    }
    
    private func showMedicalServicesIfNeeded() {
        
        let scale = self.map.region.span.latitudeDelta
        
        if scale <= MedicalServiceAnnotation.mapScaleThreshold {
            
            if !annotationDisplayCache.isShowingAnnotations(for: MedicalServiceAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: MedicalServiceAnnotation.self)
                self.map.addAnnotations(festivalGeoData?.medicalService.map { $0.toAnnotation() } ?? [])
                self.annotationDisplayCache.setShowingAnnotations(true, for: MedicalServiceAnnotation.displayCacheKey)
            }
            
        } else {
            
            if annotationDisplayCache.isShowingAnnotations(for: MedicalServiceAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: MedicalServiceAnnotation.self)
                self.annotationDisplayCache.setShowingAnnotations(false, for: MedicalServiceAnnotation.displayCacheKey)
            }
            
        }
        
    }
    
    private func showDorfServicesIfNeeded() {
        
        let scale = self.map.region.span.latitudeDelta
        
        if scale <= DorfAnnotation.mapScaleThreshold {
            
            if !annotationDisplayCache.isShowingAnnotations(for: DorfAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: DorfAnnotation.self)
                self.map.addAnnotations(festivalGeoData?.dorf.map { $0.toAnnotation() } ?? [])
                self.annotationDisplayCache.setShowingAnnotations(true, for: DorfAnnotation.displayCacheKey)
            }
            
        } else {
            
            if annotationDisplayCache.isShowingAnnotations(for: DorfAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: DorfAnnotation.self)
                self.annotationDisplayCache.setShowingAnnotations(false, for: DorfAnnotation.displayCacheKey)
            }
            
        }
        
    }
    
    private func showTransportationIfNeeded() {
        
        let scale = self.map.region.span.latitudeDelta
        
        if scale <= BikeAnnotation.mapScaleThreshold {
            
            if !annotationDisplayCache.isShowingAnnotations(for: BikeAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: BikeAnnotation.self)
                self.map.addAnnotations(festivalGeoData?.transporation.map { $0.toAnnotation() } ?? [])
                self.annotationDisplayCache.setShowingAnnotations(true, for: BikeAnnotation.displayCacheKey)
            }
            
        } else {
            
            if annotationDisplayCache.isShowingAnnotations(for: BikeAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: BikeAnnotation.self)
                self.annotationDisplayCache.setShowingAnnotations(false, for: BikeAnnotation.displayCacheKey)
            }
            
        }
        
    }
    
    private func showTicketsIfNeeded() {
        
        let scale = self.map.region.span.latitudeDelta
        
        if scale <= TicketAnnotation.mapScaleThreshold {
            
            if !annotationDisplayCache.isShowingAnnotations(for: TicketAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: TicketAnnotation.self)
                self.map.addAnnotations(festivalGeoData?.tickets.map { $0.toAnnotation() } ?? [])
                self.annotationDisplayCache.setShowingAnnotations(true, for: TicketAnnotation.displayCacheKey)
            }
            
        } else {
            
            if annotationDisplayCache.isShowingAnnotations(for: TicketAnnotation.displayCacheKey) {
                self.removeAnnotations(ofType: TicketAnnotation.self)
                self.annotationDisplayCache.setShowingAnnotations(false, for: TicketAnnotation.displayCacheKey)
            }
            
        }
        
    }
    
    private func showAnnotationsIfNeeded() {
        self.showDorfServicesIfNeeded()
        self.showToiletsIfNeeded()
        self.showMedicalServicesIfNeeded()
        self.showTransportationIfNeeded()
        self.showTicketsIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradient.frame = blur.bounds
    }
    
    // MARK: - Data
    
    private func setupListeners() {
        
        repository.store
            .changeObserver()
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (records: [PlaceRecord]) in
                
                let annotations = self.map.annotations.filter { $0 is GenericAnnotation }
                
                self.map.removeAnnotations(annotations)
                
                let markers = records.map {
                    VenueAnnotation(
                        title: $0.name,
                        coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                        placeID: $0.id.toInt() ?? 0
                    )
                }
                
                for marker in markers {
                    self.map.addAnnotation(marker)
                }
                
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - External Actions -
    
    public func focus(feature: DorfFeature) {
        
        let camera = MKMapCamera(
            lookingAtCenter: feature.toAnnotation().coordinate,
            fromDistance: 50,
            pitch: 0,
            heading: 0
        )
        
        map.setCamera(camera, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            
            let found = self.map.annotations.first { annotation in
                let feature = feature.toAnnotation()
                return annotation.coordinate == feature.coordinate
                && annotation.title == feature.title
            }
            
            if let found {
                self.map.selectAnnotation(found, animated: true)
            }
            
        }
        
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is ParkMapOverlay {
            return FestivalhalleMapOverlayView(
                overlay: overlay,
                overlayImage: UIImage(imageLiteralResourceName: "festivalhalle")
            )
        }
        
        guard let shape = overlay as? (MKShape & MKGeoJSONObject),
              let feature = currentFeatures.first( where: { $0.geometry.contains( where: { $0 == shape }) }) else {
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
        
        // Configure the overlay renderer's display properties in feature-specific ways.
        feature.configure(overlayRenderer: renderer)
        
        return renderer
        
        
        
        
        
//        if let polyline = overlay as? MKPolyline {
//
//            let renderer = MKPolylineRenderer(polyline: polyline)
//
//            renderer.strokeColor = UIColor.red
//            renderer.lineCap = .round
//            renderer.lineWidth = 6
//            renderer.alpha = 0.5
//
//            return renderer
//
//        } else if let polygon = overlay as? MKPolygon {
//
//            let renderer = MKPolygonRenderer(polygon: polygon)
//
//            renderer.strokeColor = UIColor.systemBlue
//            renderer.lineWidth = 1
//            renderer.fillColor = UIColor.systemBlue.lighter(by: 5)?.withAlphaComponent(0.3)
//
//            return renderer
//
//        } else if let polygon = overlay as? MKMultiPolygon {
//
//            let renderer = ToiletRenderer(multiPolygon: polygon)
//
//            return renderer
//
//        }
        
//        if overlay is ParkMapOverlay {
//            return ParkMapOverlayView(overlay: overlay, overlayImage: )
//        } else if overlay is MKPolyline {
//            let lineView = MKPolylineRenderer(overlay: overlay)
//            lineView.strokeColor = UIColor.green
//            return lineView
//        } else if overlay is MKPolygon {
//            let polygonView = MKPolygonRenderer(overlay: overlay)
//            polygonView.strokeColor = UIColor.magenta
//            return polygonView
//        } else if let character = overlay as? Character {
//            let circleView = MKCircleRenderer(overlay: character)
//            circleView.strokeColor = character.color
//            return circleView
//        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        } else if let cluster = annotation as? MKClusterAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.cluster) as? MKMarkerAnnotationView
            
            if view == nil { view = ClusterAnnotationView(annotation: nil, reuseIdentifier: AnnotationIdentifier.cluster) }
            
            view?.annotation = cluster
            view?.collisionMode = .circle
            
            return view
            
        } else if let tracker = annotation as? TrackerAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.tracker) as? TrackerAnnotationView
            
            if view == nil { view = TrackerAnnotationView(annotation: annotation, reuseIdentifier: AnnotationIdentifier.tracker) }
            
            view?.annotation = tracker
            
            return view
            
        } else if let genericAnnotation = annotation as? GenericAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.generic) as? GenericAnnotationView
            
            if view == nil { view = GenericAnnotationView(annotation: genericAnnotation, reuseIdentifier: AnnotationIdentifier.generic) }
            
            view?.annotation = genericAnnotation
            
            return view
            
        } else if let toiletAnnotation = annotation as? ToiletAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "toiletAnnotation") as? ToiletAnnotationView
            
            if view == nil { view = ToiletAnnotationView(annotation: annotation, reuseIdentifier: "toiletAnnotation") }
            
            view?.annotation = toiletAnnotation
            
            return view
            
        } else if let venueAnnotation = annotation as? VenueAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "venueAnnotation") as? VenueAnnotationView
            
            if view == nil { view = VenueAnnotationView(annotation: annotation, reuseIdentifier: "venueAnnotation") }
            
            view?.annotation = venueAnnotation
            
            return view
            
        } else if let annotation = annotation as? MedicalServiceAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "medicalServiceAnnotation") as? MedicalServiceAnnotationView
            
            if view == nil { view = MedicalServiceAnnotationView(annotation: annotation, reuseIdentifier: "medicalServiceAnnotation") }
            
            view?.annotation = annotation
            
            return view
            
        } else if let annotation = annotation as? DorfAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "dorfAnnotation") as? DorfAnnotationView
            
            if view == nil { view = DorfAnnotationView(annotation: annotation, reuseIdentifier: "dorfAnnotation") }
            
            view?.annotation = annotation
            
            return view
            
        } else if let annotation = annotation as? BikeAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "bikeAnnotation") as? BikeAnnotationView
            
            if view == nil { view = BikeAnnotationView(annotation: annotation, reuseIdentifier: "bikeAnnotation") }
            
            view?.annotation = annotation
            
            return view
            
        } else if let annotation = annotation as? TicketAnnotation {
            
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "ticketAnotation") as? TicketAnnotationView
            
            if view == nil { view = TicketAnnotationView(annotation: annotation, reuseIdentifier: "ticketAnotation") }
            
            view?.annotation = annotation
            
            return view
            
        }
        
        return nil
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? VenueAnnotation {
            coordinator.coordinator?.showPlaceDetail(placeID: annotation.placeID)
        }
                
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if let _ = view.annotation as? TrackerAnnotation {
            
            self.map.removeOverlays(map.overlays.filter { $0 is MKPolyline })
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        showAnnotationsIfNeeded()
        
    }
    
}

extension MapViewController: TrackerDatasource {
    
    func didReceiveTrackers(_ trackers: [Tracker]) {
        
        print("---- Received Map Trackers ----")
        
        DispatchQueue.main.async {
            
            if ConfigManager.shared.showTracker {
                
                let annotations = self.map.annotations.filter { $0 is TrackerAnnotation }
                
                self.map.removeAnnotations(annotations)
                
                for tracker in trackers {
                    
                    self.map.addAnnotation(TrackerAnnotation(tracker: tracker))
                    
                }
                
                if let lastUpdate = TrackerManager.shared.lastUpdate {
                    
                    let dateString = lastUpdate.format(format: "dd.MM. HH:mm:ss")
                    
                    self.statusLabel.isHidden = false
                    self.statusLabel.text = "\(String.localized("LastUpdate")): \(dateString)"
                    
                }
                
            } else {
                
                self.statusLabel.isHidden = true
                
            }
            
        }
        
    }
    
}

extension MapViewController: LocationDatasource {
    
    func didReceiveLocations(_ locations: [Entry]) {
        
        
    }
    
}

struct AnnotationIdentifier {
    
    static let cluster = "cluster"
    static let generic = "generic"
    static let tracker = "tracker"
    
}
