//
//  MainViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Pulley
import EventBus

class MainViewController: PulleyViewController {

    private let eventBus = EventBus()
    
    public var mapViewController: MapViewController!
    public var contentViewController: ContentViewController!
    public lazy var detailViewController: DetailViewController! = { DetailViewController() }()
    
    public var locations: [Location] = []
    
    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
        
        self.displayMode = .automatic
        
        self.mapViewController = contentViewController as? MapViewController
        self.contentViewController = drawerViewController as? ContentViewController
        
        self.setupObserver()
        self.loadData()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localized("MapTabItem")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.shared.logOpenedMaps()
        
    }
    
    // MARK: - Private Methods
    
    private func setupObserver() {
        
        self.eventBus.add(subscriber: contentViewController, for: EntryDatasource.self)
        self.eventBus.add(subscriber: contentViewController, for: ParkingLotDatasource.self)
        self.eventBus.add(subscriber: contentViewController, for: CameraDatasource.self)
        self.eventBus.add(subscriber: contentViewController, for: PetrolDatasource.self)
        
        self.eventBus.add(subscriber: mapViewController, for: EntryDatasource.self)
        self.eventBus.add(subscriber: mapViewController, for: ParkingLotDatasource.self)
        self.eventBus.add(subscriber: mapViewController, for: CameraDatasource.self)
        self.eventBus.add(subscriber: mapViewController, for: PetrolDatasource.self)
        
    }
    
    private func loadData() {
        
        OperationQueue.main.addOperation {
            
            self.loadEntries()
            self.loadParkingLots()
            self.loadPetrolStations()
            self.loadCameras()
            
        }
        
    }
    
    private func loadEntries() {
        
        EntryManager.shared.get { (error, entries) in
            
            if let error = error {
                print(error)
            }
            
            guard let entries = entries else { return }
            
            self.eventBus.notify(EntryDatasource.self, closure: { subscriber in
                subscriber.didReceiveEntries(entries)
            })
            
            self.locations = self.locations.filter { !($0 is Entry) }
            self.locations.append(contentsOf: entries)
            
        }
        
    }
    
    private func loadParkingLots() {
        
        ParkingLotManager.shared.get { (error, parkingLots) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let parkingLots = parkingLots else { return }
            
            self.eventBus.notify(ParkingLotDatasource.self) { subscriber in
                subscriber.didReceiveParkingLots(parkingLots)
            }
            
            self.locations = self.locations.filter { !($0 is ParkingLot) }
            self.locations.append(contentsOf: parkingLots)
            
        }
        
    }
    
    private func loadCameras() {
        
        CameraManager.shared.get { (error, cameras) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let cameras = cameras else { return }
            
            self.eventBus.notify(CameraDatasource.self) { subscriber in
                subscriber.didReceiveCameras(cameras)
            }
            
            self.locations = self.locations.filter { !($0 is Camera) }
            self.locations.append(contentsOf: cameras)
            
        }
        
    }
    
    private func loadPetrolStations() {
        
        let stations = PetrolManager.shared.cachedStations ?? []
        
        self.eventBus.notify(PetrolDatasource.self) { subscriber in
            subscriber.didReceivePetrolStations(stations)
        }
        
        self.locations = self.locations.filter { !($0 is PetrolStation) }
        self.locations.append(contentsOf: stations)
        
    }
    
}
