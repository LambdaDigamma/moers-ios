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
import MMAPI
import CoreLocation

class MainViewController: PulleyViewController {

    public var mapViewController: MapViewController!
    public var contentViewController: ContentViewController!
    public var locations: [Location] = []
    public lazy var detailViewController = { DetailViewController(locationManager: locationManager) }()
    
    private let locationManager: LocationManagerProtocol
    private let petrolManager: PetrolManagerProtocol
    private let cameraManager: CameraManagerProtocol
    private let entryManager: EntryManagerProtocol
    private let parkingLotManager: ParkingLotManagerProtocol
    private let eventBus: EventBus
    
    required init(contentViewController: UIViewController,
                  drawerViewController: UIViewController,
                  locationManager: LocationManagerProtocol,
                  petrolManager: PetrolManagerProtocol,
                  cameraManager: CameraManagerProtocol,
                  entryManager: EntryManagerProtocol,
                  parkingLotManager: ParkingLotManagerProtocol) {
        
        self.eventBus = EventBus()
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        self.parkingLotManager = parkingLotManager
        
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
    
    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        fatalError("init(contentViewController:drawerViewController:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = String.localized("MapTabItem")
        
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
    
    public func loadData() {
        
        self.locations.removeAll()
        
        OperationQueue.main.addOperation {
            
            self.loadEntries()
            self.loadParkingLots()
            self.loadPetrolStations()
            self.loadCameras()
            
        }
        
    }
    
    private func loadEntries() {
        
        entryManager.get { (result) in
            
            switch result {
                
            case .success(let entries):
                
                self.eventBus.notify(EntryDatasource.self, closure: { subscriber in
                    subscriber.didReceiveEntries(entries)
                })
                
                self.locations = self.locations.filter { !($0 is Entry) }
                self.locations.append(contentsOf: entries)
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
    private func loadParkingLots() {
        
        parkingLotManager.get { (result) in
            
            switch result {
                
            case .success(let parkingLots):
                
                self.eventBus.notify(ParkingLotDatasource.self) { subscriber in
                    subscriber.didReceiveParkingLots(parkingLots)
                }
                
                self.locations = self.locations.filter { !($0 is ParkingLot) }
                self.locations.append(contentsOf: parkingLots)
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
            
            
        }
        
    }
    
    private func loadCameras() {
        
        let cameras = cameraManager.getCameras(shouldReload: false)
        
        cameras.observeNext { (cameras: [Camera]) in
            
            self.eventBus.notify(CameraDatasource.self) { subscriber in
                subscriber.didReceiveCameras(cameras)
            }
            
            self.locations = self.locations.filter { !($0 is Camera) }
            self.locations.append(contentsOf: cameras)
            
        }.dispose(in: bag)
        
        cameras.observeFailed { (error: Error) in
            print(error.localizedDescription)
        }.dispose(in: bag)
        
    }
    
    private func loadPetrolStations() {
        
        let preferredPetrolType = petrolManager.petrolType
        
        let petrolStations = petrolManager.getPetrolStations(coordinate: CLLocationCoordinate2D(latitude: 51.4516, longitude: 6.6255),
                                                             radius: 10,
                                                             sorting: .distance,
                                                             type: preferredPetrolType,
                                                             shouldReload: false)
        
        petrolStations.observeNext { stations in
            
            self.eventBus.notify(PetrolDatasource.self) { subscriber in
                subscriber.didReceivePetrolStations(stations)
            }
            
            self.locations = self.locations.filter { !($0 is PetrolStation) }
            self.locations.append(contentsOf: stations)
            
        }.dispose(in: bag)
        
    }
    
    // MARK: - Public Methods
    
    public func addLocation(_ location: Location) {
        
        self.locations.append(location)
        
        self.mapViewController.addLocation(location)
        self.contentViewController.addLocation(location)
        
    }
    
}
