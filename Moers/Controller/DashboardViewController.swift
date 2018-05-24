//
//  DashboardViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import UserNotifications
import CoreLocation
import MapKit

class DashboardViewController: UIViewController, LocationManagerDelegate, PetrolManagerDelegate {

    // MARK: - UI
    
    lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
        
    }()
    
    lazy var cardStackView: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    lazy var notificationCardView: DashboardNotificationCardView = {
        
        let cardView = DashboardNotificationCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.titleLabel.text = "Was weiß ich"
        cardView.subtitleLabel.text = "Morgen um 16 Uhr..."
        
        return cardView
        
    }()
    
    lazy var rubbishCardView: DashboardRubbishCardView = {
        
        let cardView = DashboardRubbishCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRubbishCollectionViewController)))
        
        return cardView
        
    }()
    
    lazy var averagePetrolCardView: DashboardAveragePetrolPriceCardView = {
        
        let cardView = DashboardAveragePetrolPriceCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    let locationManager = LocationManager()
    
    var cards: [CardView] {
        return [averagePetrolCardView, rubbishCardView]
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(scrollView)
        self.scrollView.addSubview(cardStackView)
        
        self.setupCards(cards)
        self.setupConstraints()
        self.setupTheming()
        
        self.loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadPetrolData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationManager.stopMonitoring()
        self.averagePetrolCardView.stopLoading()
        self.rubbishCardView.stopLoading()
        
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                           cardStackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 16),
                           cardStackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: -16),
                           cardStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 16),
                           cardStackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -16),
                           cardStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -32)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.cards.forEach { $0.backgroundColor = theme.cardBackgroundColor }
            
        }
        
    }

    public func loadData() {
        
        self.rubbishCardView.startLoading()
        
        let queue = OperationQueue()
        
        queue.addOperation {
            if AppConfig.shared.loadData {
                self.loadRubbishData()
            }
        }
        
    }
    
    private func loadRubbishData() {
        
        if RubbishManager.shared.isEnabled {
            
            RubbishManager.shared.loadItems(completion: { (items) in
                
                OperationQueue.main.addOperation {
                    
                    self.rubbishCardView.stopLoading()
                    
                    if items.count >= 3 {
                        self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                        self.rubbishCardView.itemView2.rubbishCollectionItem = items[1]
                        self.rubbishCardView.itemView3.rubbishCollectionItem = items[2]
                    } else if items.count >= 2 {
                        self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                        self.rubbishCardView.itemView2.rubbishCollectionItem = items[1]
                    } else if items.count >= 1 {
                        self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                    }
                    
                }
                
            })
            
        }
        
    }
    
    private func loadPetrolData() {
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if self.locationManager.authorizationStatus != .denied {
            self.locationManager.requestCurrentLocation()
            self.averagePetrolCardView.startLoading()
        } else {
            self.averagePetrolCardView.showError(withTitle: "Berechtigung fehlt", message: "Die App darf nicht auf deinen aktuellen Standort zugreifen, um aktuelle Spritpreise zu berechnen.")
        }
        
    }
    
    private func setupCards(_ cards: [CardView]) {
        
        cards.forEach { cardStackView.addArrangedSubview($0) }
        
    }
    
    @objc private func showRubbishCollectionViewController() {
        
        let rubbishCollectionViewController = RubbishCollectionViewController()
        self.navigationController?.pushViewController(rubbishCollectionViewController, animated: true)
        
    }
    
    // MARK: - LocationManagerDelegate
    
    func didReceiveCurrentLocation(location: CLLocation) {
        
        GeocodingManager.shared.city(from: location) { (city) in
            
            self.averagePetrolCardView.locationLabel.text = city
            
        }
        
        GeocodingManager.shared.countryCode(from: location) { (countryCode) in
            
            if countryCode != "DE" {
                
                self.averagePetrolCardView.showError(withTitle: "Spritinformationen", message: "Nur in Deutschland verfügbar")
                
            } else {
                
                PetrolManager.shared.delegate = self
                PetrolManager.shared.sendRequest(coordiante: location.coordinate, radius: 10.0, sorting: .distance, type: .diesel)
                
            }
            
        }
        
    }
    
    func didFailWithError(error: Error) {
        
        
        
    }
    
    // MARK: - PetrolManagerDelegate
    
    func didReceivePetrolStations(stations: [PetrolStation]) {
        
        DispatchQueue.main.async {
            
            let openStations = stations.filter { $0.isOpen }
            
            self.averagePetrolCardView.stopLoading()
            self.averagePetrolCardView.numberOfStations = openStations.count
            
            let sum = openStations.reduce(0) { (result, item) in
                
                return result + (item.price ?? 0)
                
            }
            
            let averagePrice = sum / Double(openStations.count)
            
            self.averagePetrolCardView.price = averagePrice
            
        }
        
    }
    
}
