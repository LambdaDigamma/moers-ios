//
//  FestivalMapView.swift
//  moers festival
//
//  Created by Codex on 05.04.26.
//

import UIKit
import MapKit

final class FestivalMapView: MKMapView {

    private enum AttributionViewClass {
        static let attributionLabel = "MKAttributionLabel"
        static let appleLogoLabel = "MKAppleLogoLabel"
    }

    private weak var attributionLabelView: UIView?
    private weak var appleLogoLabelView: UIView?

    private let horizontalPadding: CGFloat = 12
    private let verticalPadding: CGFloat = 8

    override func layoutSubviews() {
        super.layoutSubviews()
        updateAttributionPosition()
    }

    private func updateAttributionPosition() {
        guard let attributionView = resolvedAttributionView(),
              let appleLogoView = resolvedAppleLogoView(),
              let attributionSuperview = attributionView.superview,
              let appleLogoSuperview = appleLogoView.superview else {
            return
        }

        let orderedViews = [appleLogoView, attributionView].sorted {
            convert($0.frame, from: $0.superview).minX < convert($1.frame, from: $1.superview).minX
        }

        let leftView = orderedViews[0]
        let rightView = orderedViews[1]

        let leftFrameInMap = convert(leftView.frame, from: leftView.superview)
        let rightFrameInMap = convert(rightView.frame, from: rightView.superview)
        let spacing = max(rightFrameInMap.minX - leftFrameInMap.maxX, 4)

        let totalWidth = leftFrameInMap.width + spacing + rightFrameInMap.width
        let maxHeight = max(leftFrameInMap.height, rightFrameInMap.height)

        let targetLeftFrameInMap = CGRect(
            x: bounds.width - safeAreaInsets.right - horizontalPadding - totalWidth,
            y: bounds.height - safeAreaInsets.bottom - verticalPadding - maxHeight,
            width: leftFrameInMap.width,
            height: leftFrameInMap.height
        )

        let targetRightFrameInMap = CGRect(
            x: targetLeftFrameInMap.maxX + spacing,
            y: targetLeftFrameInMap.minY + ((maxHeight - rightFrameInMap.height) / 2),
            width: rightFrameInMap.width,
            height: rightFrameInMap.height
        )

        let centeredLeftFrameInMap = CGRect(
            x: targetLeftFrameInMap.minX,
            y: targetLeftFrameInMap.minY + ((maxHeight - leftFrameInMap.height) / 2),
            width: targetLeftFrameInMap.width,
            height: targetLeftFrameInMap.height
        )

        let targetAttributionFrameInMap = leftView === attributionView ? centeredLeftFrameInMap : targetRightFrameInMap
        let targetAppleLogoFrameInMap = leftView === appleLogoView ? centeredLeftFrameInMap : targetRightFrameInMap

        attributionView.frame = attributionSuperview.convert(targetAttributionFrameInMap, from: self)
        appleLogoView.frame = appleLogoSuperview.convert(targetAppleLogoFrameInMap, from: self)
    }

    private func firstSubview(named className: String) -> UIView? {
        allSubviews.first {
            NSStringFromClass(type(of: $0)).contains(className)
        }
    }

    private func resolvedAttributionView() -> UIView? {
        if let attributionLabelView, attributionLabelView.isDescendant(of: self) {
            return attributionLabelView
        }

        let view = firstSubview(named: AttributionViewClass.attributionLabel)
        attributionLabelView = view
        return view
    }

    private func resolvedAppleLogoView() -> UIView? {
        if let appleLogoLabelView, appleLogoLabelView.isDescendant(of: self) {
            return appleLogoLabelView
        }

        let view = firstSubview(named: AttributionViewClass.appleLogoLabel)
        appleLogoLabelView = view
        return view
    }
}

private extension UIView {
    var allSubviews: [UIView] {
        subviews + subviews.flatMap(\.allSubviews)
    }
}
