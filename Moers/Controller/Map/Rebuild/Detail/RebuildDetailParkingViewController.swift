//
//  RebuildDetailParkingViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class RebuildDetailParkingViewController: UIViewController {

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
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.topSeparator.backgroundColor = theme.decentColor
            themeable.middleSeparator.backgroundColor = theme.decentColor
            themeable.slotsHeaderLabel.textColor = theme.color
            themeable.totalHeaderLabel.textColor = theme.color
            themeable.totalLabel.textColor = theme.color
            themeable.freeHeaderLabel.textColor = theme.color
            themeable.freeLabel.textColor = theme.color
            themeable.statusHeaderLabel.textColor = theme.color
            themeable.statusLabel.textColor = theme.color
            themeable.addressHeaderLabel.textColor = theme.color
            themeable.addressLabel.textColor = theme.color
            
        }
        
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
        statusLabel.text = localizedStatus(status: parkingLot.status)
        addressLabel.text = parkingLot.address
        
    }
    
    private func localizedStatus(status: Status) -> String {
        
        switch status {
        case .ascends: return String.localized("ParkingLotAscends")
        case .descends: return String.localized("ParkingLotDescends")
        case .unchanged: return String.localized("ParkingLotUnchanged")
        case .undocumented: return String.localized("ParkingLotUndocumented")
        }
        
    }
    
}
