//
//  DetailParkingViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class DetailParkingViewController: UIViewController {

    @IBOutlet weak var slotsLabel: UILabel!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    
    var selectedParkingLot: ParkingLot? {
        
        didSet {
            
            guard let parkingLot = selectedParkingLot else { return }
            
            slotsLabel.text = "\(parkingLot.slots)"
            freeLabel.text = "\(parkingLot.free)"
            statusLabel.text = "\(parkingLot.status.rawValue) ↘︎"
            streetLabel.text = parkingLot.address
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

}
