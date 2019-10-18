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
                           topSeparator.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           topSeparator.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           topSeparator.heightAnchor.constraint(equalToConstant: 1),
                           slotsHeaderLabel.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 8),
                           slotsHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           slotsHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           totalHeaderLabel.topAnchor.constraint(equalTo: slotsHeaderLabel.bottomAnchor, constant: 8),
                           totalHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           totalLabel.topAnchor.constraint(equalTo: totalHeaderLabel.topAnchor),
                           totalLabel.leftAnchor.constraint(equalTo: totalHeaderLabel.rightAnchor, constant: 8),
                           totalLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           totalLabel.widthAnchor.constraint(equalTo: totalHeaderLabel.widthAnchor),
                           freeHeaderLabel.topAnchor.constraint(equalTo: totalHeaderLabel.bottomAnchor, constant: 8),
                           freeHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           freeLabel.topAnchor.constraint(equalTo: freeHeaderLabel.topAnchor),
                           freeLabel.leftAnchor.constraint(equalTo: freeHeaderLabel.rightAnchor, constant: 8),
                           freeLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           freeLabel.widthAnchor.constraint(equalTo: freeHeaderLabel.widthAnchor),
                           statusHeaderLabel.topAnchor.constraint(equalTo: freeHeaderLabel.bottomAnchor, constant: 8),
                           statusHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           statusLabel.topAnchor.constraint(equalTo: statusHeaderLabel.topAnchor),
                           statusLabel.leftAnchor.constraint(equalTo: statusHeaderLabel.rightAnchor, constant: 8),
                           statusLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           statusLabel.widthAnchor.constraint(equalTo: statusHeaderLabel.widthAnchor),
                           middleSeparator.topAnchor.constraint(equalTo: statusHeaderLabel.bottomAnchor, constant: 8),
                           middleSeparator.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           middleSeparator.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           middleSeparator.heightAnchor.constraint(equalToConstant: 1),
                           addressHeaderLabel.topAnchor.constraint(equalTo: middleSeparator.bottomAnchor, constant: 8),
                           addressHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           addressHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           addressLabel.topAnchor.constraint(equalTo: addressHeaderLabel.bottomAnchor, constant: 8),
                           addressLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           addressLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupParkingLot(_ parkingLot: ParkingLot?) {
        
        guard let parkingLot = selectedParkingLot else { return }
        
        totalLabel.text = "\(parkingLot.slots)"
        freeLabel.text = "\(parkingLot.free)"
        statusLabel.text = ParkingLotStatus.localizedForCase(parkingLot.status)
        addressLabel.text = parkingLot.address
        
        Answers.logCustomEvent(withName: "Detail - Parking Lot", customAttributes:
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