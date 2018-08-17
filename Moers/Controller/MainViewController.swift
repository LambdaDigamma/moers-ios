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
    
    public var mapViewController: RebuildMapViewController!
    public var contentViewController: RebuildContentViewController!
    public lazy var detailViewController: RebuildDetailViewController! = { RebuildDetailViewController() }()
    
    public var locations: [Location] = []
    
    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
        
        self.mapViewController = contentViewController as! RebuildMapViewController
        self.contentViewController = drawerViewController as! RebuildContentViewController
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.eventBus.add(subscriber: contentViewController, for: ShopDatasource.self)
        self.eventBus.add(subscriber: contentViewController, for: ParkingLotDatasource.self)
        self.eventBus.add(subscriber: contentViewController, for: CameraDatasource.self)
        
        self.eventBus.add(subscriber: mapViewController, for: ShopDatasource.self)
        self.eventBus.add(subscriber: mapViewController, for: ParkingLotDatasource.self)
        self.eventBus.add(subscriber: mapViewController, for: CameraDatasource.self)
        
        self.loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.shared.logOpenedMaps()
        
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        
        OperationQueue.main.addOperation {
            
            self.loadShops()
            self.loadParkingLots()
            self.loadCameras()
            
        }
        
    }
    
    private func loadShops() {
        
        ShopManager.shared.get { (error, shops) in
            
            if let error = error {
                print(error)
            }
            
            guard let shops = shops else { return }
            
            self.eventBus.notify(ShopDatasource.self) { subscriber in
                subscriber.didReceiveShops(shops)
            }
            
            self.locations = self.locations.filter { !($0 is Store) }
            self.locations.append(contentsOf: shops)
            
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
    
}
