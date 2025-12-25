//
//  MapSnapshotView.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import SwiftUI
import MapKit

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

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
        
        ZStack {
            
            Color(UIColor.secondarySystemBackground)
            
            if let image = snapshotImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
        }
        .background(
            ZStack {
                // Placeholder
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .readSize(onChange: { size in
                    generateSnapshot(width: size.width, height: size.height)
                })
        )
        .frame(maxWidth: .infinity)
        
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        if width == 0 || height == 0 || (width == 20 && height == 20) {
            return
        }
        
        let size = CGSize(width: width, height: height)
        let trait = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        let annotationViews: [MKMarkerAnnotationView] = annotations.map { self.generateMapMarker(annotation: $0) }
        
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
            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            .previewLayout(.sizeThatFits)
        MapSnapshotView(location: coordinates)
            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

#endif
