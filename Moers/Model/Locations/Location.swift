//
//  Location.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol Location: DetailPresentable, Categorizable, Fuseable, MKAnnotation {
    
    var location: CLLocation { get }
    var name: String { get }
    var tags: [String] { get }
    var distance: Double { get }
    
}

protocol DetailPresentable {
    
    var detailHeight: CGFloat { get }
    var detailSubtitle: String { get }
    var detailImage: UIImage { get }
    var detailViewController: UIViewController { get }
    
}

protocol Categorizable {
    
    var category: String { get }
    var localizedCategory: String { get }
    
}
