//
//  LocationPreviewViewController.swift
//  MMUI
//
//  Created by Lennart Fischer on 26.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import UIKit
import MapKit
import Combine

class LocationPreviewViewController: UIViewController {

    public let viewModel: LocationPreviewViewModel
    private let locationPreviewView: LocationPreviewView
    private var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: LocationPreviewViewModel) {
        self.viewModel = viewModel
        self.locationPreviewView = LocationPreviewView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = locationPreviewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String(localized: "Venue", bundle: .module)
        
        self.setupActions()
        
    }
    
    private func setupActions() {
        
        locationPreviewView.startNavigation.sink { _ in
            
            if let coordinate = self.locationPreviewView.coordinate {
                
                #if !os(tvOS)
                
                let regionDistance: CLLocationDistance = 1000
                let coordinates = CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                let regionSpan = MKCoordinateRegion(
                    center: coordinates,
                    latitudinalMeters: regionDistance,
                    longitudinalMeters: regionDistance
                )
                
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                
                mapItem.name = "\(self.viewModel.name.value)"
                mapItem.openInMaps(launchOptions: options)
                
                #endif
                
            }
            
        }
        .store(in: &cancellables)
        
    }
    
}
