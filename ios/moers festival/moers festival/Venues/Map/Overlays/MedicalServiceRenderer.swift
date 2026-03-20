//
//  MedicalServiceRenderer.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

public class MedicalServiceRenderer: MKMultiPolygonRenderer {

    nonisolated public override init(overlay: MKOverlay) {
        super.init(overlay: overlay)
        self.setupColors()
    }

    nonisolated public override init(multiPolygon: MKMultiPolygon) {
        super.init(multiPolygon: multiPolygon)
        self.setupColors()
    }

    nonisolated private func setupColors() {

        let rendererLineWidth: CGFloat = 1
        let rendererStrokeColor = UIColor.systemGreen.withAlphaComponent(0.75)
        let rendererFillColor = UIColor.systemGreen.lighter(by: 5)?
            .withAlphaComponent(0.3) ?? .clear

        MainActor.assumeIsolated {
            self.lineWidth = rendererLineWidth
            self.strokeColor = rendererStrokeColor
            self.fillColor = rendererFillColor
        }

    }

    nonisolated public override func draw(
        _ mapRect: MKMapRect,
        zoomScale: MKZoomScale,
        in context: CGContext
    ) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)

        let symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemGreen])
        let symbol = UIImage(systemName: "cross.circle.fill", withConfiguration: symbolConfiguration)

        guard let image = symbol?.cgImage else { return }
        let mapPoint = MKMapPoint(overlay.coordinate)
        let cgPoint = self.point(for: mapPoint)

        let size: Double = 30
        let rect = CGRect(
            x: cgPoint.x - (size / 2),
            y: cgPoint.y - (size / 2),
            width: size,
            height: size
        )

        context.draw(image, in: rect)

    }

}

struct MedicalServiceRenderer_Previews: PreviewProvider {

    static var previews: some View {

        let viewController = OverlayRendererPreviewController<MedicalServiceRenderer>()
        return UINavigationController(rootViewController: viewController)
            .preview

    }

}
