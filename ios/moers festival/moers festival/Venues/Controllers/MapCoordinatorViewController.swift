//
//  MapCoordinatorViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit
import Pulley
import EventBus
import Combine
import MMEvents
import Factory

class MapCoordinatorViewController: PulleyViewController {

    @LazyInjected(\.locationEventService) var locationService
    
    public var coordinator: MapCoordinator?
    
    private let eventBus = EventBus()
    
    public var mapViewController: MapViewController!
    public var drawerViewController: DrawerFestivalMapViewController!
    
    private var cancellables = Set<AnyCancellable>()
    
    public var trackers: [Tracker] = []
    public var entries: [Entry] = []
    private var timer: Timer?
    
    required init(
        contentViewController: UIViewController,
        drawerViewController: UIViewController
    ) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
        
        self.displayMode = .automatic
        
        self.mapViewController = primaryContentViewController as? MapViewController
        self.drawerViewController = drawerContentViewController as? DrawerFestivalMapViewController
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupObserver()
        self.loadData()
        
        let observer1 = NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
        let observer2 = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
        let observer3 = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
        
        observer1.sink { notification in
            self.timer?.invalidate()
        }.store(in: &cancellables)
        
    
        observer2.sink { notification in
            self.timer?.invalidate()
        }.store(in: &cancellables)
        
        observer3.sink { notification in
            self.timer?.invalidate()
        }.store(in: &cancellables)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.loadTracker()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.navigationItem.title = "Karte"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(loadData)
        )
        
        self.pulleyViewController?.drawerCornerRadius = 48
        
    }
    
    private func setupObserver() {
        
        self.eventBus.add(subscriber: mapViewController, for: TrackerDatasource.self)
//        self.eventBus.add(subscriber: drawerViewController, for: TrackerDatasource.self)
        self.eventBus.add(subscriber: mapViewController, for: LocationDatasource.self)
//        self.eventBus.add(subscriber: drawerViewController, for: LocationDatasource.self)
        
    }
    
    @objc public func loadData() {
        
        print("---- Load New Tracking Data ----")
        
//        self.loadTracker()
//        self.loadLocations()
        
        Task { [weak self] in
            guard let self else { return }

            do {
                let places = try await self.locationService.getLocations()

                print(places)

                self.entries = places.map { (place: Place) in
                    return Entry(
                        id: place.id,
                        name: place.name,
                        street: place.streetName ?? "",
                        houseNumber: place.streetNumber ?? "",
                        postcode: place.postalCode ?? "",
                        place: place.postalTown ?? "",
                        lat: place.lat,
                        lng: place.lng
                    )
                }

                self.eventBus.notify(LocationDatasource.self, closure: { subscriber in
                    subscriber.didReceiveLocations(Array(Set(self.entries)))
                })
            } catch {
                print(error)
            }
            }
        
    }
    
    @MainActor @objc private func loadTracker() {
        
//        self.trackers.removeAll()
//
//        self.mapViewController.setFetchStatus("Fetching...")
//
//        OperationQueue.main.addOperation {
//
//            let trackerObserver = TrackerManager.shared.getTrackers()
//
//            trackerObserver.sink { (completion: Subscribers.Completion<Error>) in
//
//                switch completion {
//                    case .failure(let error):
//                        self.mapViewController.setFetchStatus("Fetch failed.")
//                        print(error)
//
//                    default: break
//                }
//
//            } receiveValue: { (trackers: [Tracker]) in
//
//                print("Received \(trackers.count) Trackers")
//
//                self.trackers = trackers
//
//                self.eventBus.notify(TrackerDatasource.self, closure: { subscriber in
//                    subscriber.didReceiveTrackers(trackers)
//                })
//
//                self.mapViewController.setFetchStatus("Fetch successful.")
//
//            }
//            .store(in: &self.cancellables)
//
//        }
        
    }
    
    private func loadLocations() {

        guard let manager = self.coordinator?.eventService else { return }

        Task { [weak self] in
            guard let self else { return }

            do {
                let events = try await manager.loadEvents()

                self.entries.removeAll()
                self.poplulateEntries(with: events)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func poplulateEntries(with events: [Event]) {
        
        // TODO: Fix this
        
//        let locations = events.compactMap { $0.getLocation() }
//
//        var filtered: [Entry] = []
//
//        for location in locations {
//
//            if !filtered.contains(where: { $0.id == location.id }) {
//                filtered.append(location)
//            }
//
//        }
//
//        self.entries = filtered
//
//        self.eventBus.notify(LocationDatasource.self, closure: { subscriber in
//            subscriber.didReceiveLocations(Array(Set(filtered)))
//        })
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
}
