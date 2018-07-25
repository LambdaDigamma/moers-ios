//
//  PetrolPriceInterfaceController.swift
//  Watch Extension
//
//  Created by Lennart Fischer on 01.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import WatchKit
import Foundation


class PetrolPriceInterfaceController: WKInterfaceController/*, LocationManagerDelegate*/, PetrolManagerDelegate {
    
//    let locationManager = LocationManager()
    
    @IBOutlet var placeLabel: WKInterfaceLabel!
    @IBOutlet var priceLabel: WKInterfaceLabel!
    @IBOutlet var subtitleLabel: WKInterfaceLabel!
    
    @IBAction func show() {
        
        
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        
    }

    override func willActivate() {
        super.willActivate()
        
//        self.locationManager.delegate = self
//        self.locationManager.requestWhenInUseAuthorization {
//            self.locationManager.requestCurrentLocation()
//        }
//        self.locationManager.requestCurrentLocation()
//
//        print(locationManager.authorizationStatus == .authorizedWhenInUse)
        
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        
        
    }
    
    public func setupInterface(for place: String, price: Double, type: PetrolType) {
        
        placeLabel.setText(place)
        priceLabel.setText("\(price)€")
        
        
    }

    func didReceiveCurrentLocation(location: CLLocation) {
        
        GeocodingManager.shared.city(from: location) { (city) in
            
            self.placeLabel.setText(city)
            
        }
        
        let type: PetrolType = .diesel
        
        PetrolManager.shared.sendRequest(coordiante: location.coordinate, radius: 10.0, sorting: .distance, type: type)
        
        subtitleLabel.setText("pro L \(type.rawValue)".uppercased())
        
    }
    
    func didFailWithError(error: Error) {
        
        print(error.localizedDescription)
        
    }
    
    func didReceivePetrolStations(stations: [PetrolStation]) {
        
        DispatchQueue.main.async {
            
            let openStations = stations.filter { $0.isOpen }
            
            let sum = openStations.reduce(0) { (result, item) in
                
                return result + (item.price ?? 0)
                
            }
            
            let averagePrice = sum / Double(openStations.count)
            
            self.priceLabel.setText("\(averagePrice)€")
            
        }
        
    }
    
}
