//
//  DetailParkingViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Crashlytics
import MMAPI
import MMUI

class DetailParkingViewController: UIViewController {

    lazy var topSeparator: UIView = { ViewFactory.blankView() }()
    lazy var slotsHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var totalHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var totalLabel: UILabel = { ViewFactory.label() }()
    lazy var freeHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var freeLabel: UILabel = { ViewFactory.label() }()
    lazy var statusHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var statusLabel: UILabel = { ViewFactory.label() }()
    lazy var middleSeparator: UIView = { ViewFactory.blankView() }()
    lazy var addressHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var addressLabel: UILabel = { ViewFactory.label() }()
    
    var selectedParkingLot: ParkingLot? { didSet { setupParkingLot(selectedParkingLot) } }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.view.addSubview(topSeparator)
        self.view.addSubview(slotsHeaderLabel)
        self.view.addSubview(totalHeaderLabel)
        self.view.addSubview(totalLabel)
        self.view.addSubview(freeHeaderLabel)
        self.view.addSubview(freeLabel)
        self.view.addSubview(statusHeaderLabel)
        self.view.addSubview(statusLabel)
        self.view.addSubview(middleSeparator)
        self.view.addSubview(addressHeaderLabel)
        self.view.addSubview(addressLabel)
        
        self.slotsHeaderLabel.text = String.localized("SlotsHeader")
        self.totalHeaderLabel.text = String.localized("TotalHeader")
        self.freeHeaderLabel.text = String.localized("FreeHeader")
        self.statusHeaderLabel.text = String.localized("StatusHeader")
        self.addressHeaderLabel.text = String.localized("AddressHeader")
        
        self.topSeparator.alpha = 0.5
        self.middleSeparator.alpha = 0.5
        self.slotsHeaderLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.addressHeaderLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [topSeparator.topAnchor.constraint(equalTo: self.view.topAnchor),
                           topSeparator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           topSeparator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           topSeparator.heightAnchor.constraint(equalToConstant: 1),
                           slotsHeaderLabel.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 8),
                           slotsHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           slotsHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           totalHeaderLabel.topAnchor.constraint(equalTo: slotsHeaderLabel.bottomAnchor, constant: 8),
                           totalHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           totalLabel.topAnchor.constraint(equalTo: totalHeaderLabel.topAnchor),
                           totalLabel.leadingAnchor.constraint(equalTo: totalHeaderLabel.trailingAnchor, constant: 8),
                           totalLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           totalLabel.widthAnchor.constraint(equalTo: totalHeaderLabel.widthAnchor),
                           freeHeaderLabel.topAnchor.constraint(equalTo: totalHeaderLabel.bottomAnchor, constant: 8),
                           freeHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           freeLabel.topAnchor.constraint(equalTo: freeHeaderLabel.topAnchor),
                           freeLabel.leadingAnchor.constraint(equalTo: freeHeaderLabel.trailingAnchor, constant: 8),
                           freeLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           freeLabel.widthAnchor.constraint(equalTo: freeHeaderLabel.widthAnchor),
                           statusHeaderLabel.topAnchor.constraint(equalTo: freeHeaderLabel.bottomAnchor, constant: 8),
                           statusHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           statusLabel.topAnchor.constraint(equalTo: statusHeaderLabel.topAnchor),
                           statusLabel.leadingAnchor.constraint(equalTo: statusHeaderLabel.trailingAnchor, constant: 8),
                           statusLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           statusLabel.widthAnchor.constraint(equalTo: statusHeaderLabel.widthAnchor),
                           middleSeparator.topAnchor.constraint(equalTo: statusHeaderLabel.bottomAnchor, constant: 8),
                           middleSeparator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           middleSeparator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           middleSeparator.heightAnchor.constraint(equalToConstant: 1),
                           addressHeaderLabel.topAnchor.constraint(equalTo: middleSeparator.bottomAnchor, constant: 8),
                           addressHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           addressHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           addressLabel.topAnchor.constraint(equalTo: addressHeaderLabel.bottomAnchor, constant: 8),
                           addressLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           addressLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupParkingLot(_ parkingLot: ParkingLot?) {
        
        guard let parkingLot = selectedParkingLot else { return }
        
        totalLabel.text = "\(parkingLot.slots)"
        freeLabel.text = "\(parkingLot.free)"
        statusLabel.text = ParkingLotStatus.localizedForCase(parkingLot.status)
        addressLabel.text = parkingLot.address
        
        Analytics.logEvent("Detail - Parking Lot", parameters:
            ["name": parkingLot.name,
             "free": parkingLot.free,
             "status": parkingLot.status.rawValue])
        
    }
    
}

extension DetailParkingViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        self.topSeparator.backgroundColor = theme.decentColor
        self.middleSeparator.backgroundColor = theme.decentColor
        self.slotsHeaderLabel.textColor = theme.color
        self.totalHeaderLabel.textColor = theme.color
        self.totalLabel.textColor = theme.color
        self.freeHeaderLabel.textColor = theme.color
        self.freeLabel.textColor = theme.color
        self.statusHeaderLabel.textColor = theme.color
        self.statusLabel.textColor = theme.color
        self.addressHeaderLabel.textColor = theme.color
        self.addressLabel.textColor = theme.color
        
    }
    
}
