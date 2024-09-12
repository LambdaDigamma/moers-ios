//
//  MainViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import Pulley
import EventBus
import CoreLocation
import Combine
import Resolver
import FuelFeature

public class MainViewController: PulleyViewController {

    @LazyInjected var petrolManager: PetrolService
    
    public var coordinator: MapCoordintor? {
        didSet {
            self.detailViewController.coordinator = coordinator
        }
    }
    
    public var mapViewController: MapViewController!
    public var contentViewController: SearchDrawerViewController!
    public var locations: [Location] = []
    public lazy var detailViewController = { DetailViewController(entryManager: entryManager) }()
    
    private let cameraManager: CameraManagerProtocol
    private let entryManager: EntryManagerProtocol
    private let eventBus: EventBus
    private var cancellables = Set<AnyCancellable>()
    
    required init(
        contentViewController: UIViewController,
        drawerViewController: UIViewController,
        cameraManager: CameraManagerProtocol,
        entryManager: EntryManagerProtocol
    ) {
        
        self.eventBus = EventBus()
        self.cameraManager = cameraManager
        self.entryManager = entryManager
        
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
        
        self.displayMode = .automatic
        
        self.mapViewController = contentViewController as? MapViewController
        self.contentViewController = drawerViewController as? SearchDrawerViewController
        
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = AppStrings.Menu.map
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        AnalyticsManager.shared.logOpenedMaps()
        
    }
    
    // MARK: - Private Methods
    
    private func setupObserver() {
        
        self.eventBus.add(subscriber: contentViewController, for: EntryDatasource.self)
        self.eventBus.add(subscriber: contentViewController, for: CameraDatasource.self)
        self.eventBus.add(subscriber: contentViewController, for: PetrolDatasource.self)
        
        self.eventBus.add(subscriber: mapViewController, for: EntryDatasource.self)
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
        
//        parkingLotManager.get { (result) in
//
//            switch result {
//
//            case .success(let parkingLots):
//
//                self.eventBus.notify(ParkingLotDatasource.self) { subscriber in
//                    subscriber.didReceiveParkingLots(parkingLots)
//                }
//
//                self.locations = self.locations.filter { !($0 is ParkingLot) }
//                self.locations.append(contentsOf: parkingLots)
//
//            case .failure(let error):
//                print(error.localizedDescription)
//
//            }
//
//        }
        
    }
    
    private func loadCameras() {
        
        let cameras = cameraManager.getCameras(shouldReload: false)
        
        cameras.sink { (completion: Subscribers.Completion<Error>) in
            
            switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                default: break
            }
            
        } receiveValue: { (cameras: [Camera]) in
            
            self.eventBus.notify(CameraDatasource.self) { subscriber in
                subscriber.didReceiveCameras(cameras)
            }
            
            self.locations = self.locations.filter { !($0 is Camera) }
            self.locations.append(contentsOf: cameras)
            
        }
        .store(in: &cancellables)
        
    }
    
    private func loadPetrolStations() {
        
        let preferredPetrolType = petrolManager.petrolType
        
        let petrolStations = petrolManager.getPetrolStations(
            coordinate: CLLocationCoordinate2D(latitude: 51.4516, longitude: 6.6255),
            radius: 10,
            sorting: .distance,
            type: preferredPetrolType,
            shouldReload: false
        )
        
        petrolStations
            .receive(on: DispatchQueue.main)
            .sink { (_: Subscribers.Completion<Error>) in
                
            } receiveValue: { (stations: [FuelFeature.PetrolStation]) in
                
                let s = stations.map { (petrolStation: FuelFeature.PetrolStation) in
                    
                    return MapFeature.PetrolStationViewModel(
                        id: petrolStation.id,
                        name: petrolStation.name,
                        brand: petrolStation.name,
                        street: petrolStation.street,
                        place: petrolStation.place,
                        houseNumber: petrolStation.houseNumber,
                        postCode: petrolStation.postCode,
                        lat: petrolStation.lat, lng: petrolStation.lng,
                        dist: petrolStation.dist,
                        diesel: petrolStation.diesel,
                        e5: petrolStation.e5,
                        e10: petrolStation.e10,
                        price: petrolStation.price,
                        isOpen: petrolStation.isOpen,
                        wholeDay: petrolStation.wholeDay,
                        openingTimes: (petrolStation.openingTimes ?? []).map { p in
                            MapFeature.PetrolStationViewModel.TimeEntry(text: p.text, start: p.start, end: p.end)
                        },
                        overrides: petrolStation.overrides,
                        state: petrolStation.state
                    )
                    
                }
                
                self.eventBus.notify(PetrolDatasource.self) { subscriber in
                    subscriber.didReceivePetrolStations(s)
                }
                
                self.locations = self.locations.filter { !($0 is MapFeature.PetrolStationViewModel) }
                self.locations.append(contentsOf: stations)
                
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Public Methods
    
    public func addLocation(_ location: Location) {
        
        self.locations.append(location)
        
        self.mapViewController.addLocation(location)
        self.contentViewController.addLocation(location)
        
    }
    
}
