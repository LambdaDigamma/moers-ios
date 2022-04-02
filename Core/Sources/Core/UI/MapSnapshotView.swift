//
//  MapSnapshotView.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import SwiftUI
import MapKit

#if canImport(UIKit)

public struct MapSnapshotView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    public let location: CLLocationCoordinate2D
    public var span: CLLocationDegrees = 0.01
    public let annotations: [SnapshotAnnotation]
    
    public init(
        location: CLLocationCoordinate2D,
        span: CLLocationDegrees = 0.01,
        annotations: [SnapshotAnnotation] = []
    ) {
        self.location = location
        self.span = span
        self.annotations = annotations
    }
    
    @State private var snapshotImage: UIImage?
    
    public var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = snapshotImage {
                    Image(uiImage: image)
                } else {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        Spacer()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                }
            }
            .onAppear {
                generateSnapshot(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        let size = CGSize(width: width, height: height)
        let trait = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        let annotationViews: [MKMarkerAnnotationView] = annotations.map { self.generateMapMarker(annotation: $0) }
        
        if size == .zero {
            return
        }
        
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.traitCollection = trait
        mapOptions.size = size
        mapOptions.showsBuildings = true
        
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            if let snapshot = snapshotOrNil {
                
                let image = snapshot.image
                let finalImage = UIGraphicsImageRenderer(size: image.size).image { _ in
                    snapshot.image.draw(at: .zero)
                    
                    for view in annotationViews {
                        
                        guard let coordinate = view.annotation?.coordinate else {
                            continue
                        }
                        
                        let point = snapshot.point(for: coordinate)
                        
                        view.contentMode = .scaleAspectFit
                        view.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
                        view.drawHierarchy(
                            in: CGRect(
                                x: point.x - view.bounds.size.width / 2.0,
                                y: point.y - view.bounds.size.height,
                                width: view.bounds.width,
                                height: view.bounds.height
                            ),
                            afterScreenUpdates: true
                        )
                        
                    }
                    
                }

                self.snapshotImage = finalImage
                
            }
            
        }
        
    }
    
    func generateMapMarker(annotation: SnapshotAnnotation) -> MKMarkerAnnotationView {
        
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        switch annotation.annotationType {
            case .image(let image):
                marker.glyphImage = image
            case .text(let text):
                marker.glyphText = text
            default: break
        }
        
        marker.glyphTintColor = UIColor.white
        marker.markerTintColor = UIColor.systemBlue
        
        return marker
        
    }
    
}

public class SnapshotAnnotation: NSObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D
    public var annotationType: SnapshotAnnotationType?
    
    public init(
        coordinate: CLLocationCoordinate2D,
        annotationType: SnapshotAnnotationType? = nil
    ) {
        self.coordinate = coordinate
        self.annotationType = annotationType
    }
    
    public init(
        point: Point,
        annotationType: SnapshotAnnotationType? = nil
    ) {
        self.coordinate = point.toCoordinate()
        self.annotationType = annotationType
    }
    
    public enum SnapshotAnnotationType {
        case image(UIImage)
        case text(String)
    }
    
}

struct MapSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinates = CLLocationCoordinate2D(
            latitude: 37.332077,
            longitude: -122.02962
        )
        MapSnapshotView(location: coordinates)
            .frame(maxWidth: 200, maxHeight: 200)
            .previewLayout(.sizeThatFits)
    }
}

#endif
