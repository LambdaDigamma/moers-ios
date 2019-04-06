//
//  Camera.swift
//  Moers
//
//  Created by Lennart Fischer on 24.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

typealias PanoID = Int

class Camera: NSObject, Location {

    @objc dynamic var name: String
    var location: CLLocation
    var panoID: PanoID

    init(name: String, location: CLLocation, panoID: PanoID) {

        self.name = name
        self.location = location

        self.panoID = panoID

    }



    // MARK: - Search
    
    var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }

    // MARK: - Location

    lazy var distance: Double = {
        if let location = LocationManager.shared.lastLocation {
            return location.distance(from: self.location)
        } else {
            return 0
        }
    }()

    var tags: [String] {
        return [localizedCategory]
    }

    // MARK: - MKAnnotation

    var coordinate: CLLocationCoordinate2D { return location.coordinate }
    var title: String? { return self.name }
    var subtitle: String? { return nil }

    // MARK: - Categorizable

    var category: String { return "Camera" }
    var localizedCategory: String { return String.localized("Camera") }

    // MARK: - DetailRepresentable

    var detailSubtitle: String {

        if LocationManager.shared.authorizationStatus == .authorizedAlways ||
            LocationManager.shared.authorizationStatus == .authorizedWhenInUse {

            let dist = prettifyDistance(distance: distance)

            return "\(dist) • \(localizedCategory)"

        } else {
            return localizedCategory
        }

    }

    var detailHeight: CGFloat = 80.0
    lazy var detailImage: UIImage = { return #imageLiteral(resourceName: "camera") }()
    lazy var detailViewController: UIViewController = { DetailCameraViewController() }()

}
