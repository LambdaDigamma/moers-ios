import SwiftUI
import UIKit

struct ReadableContentWidthMeasurement: UIViewControllerRepresentable {
    let includeLayoutMargins: Bool
    let onWidthChange: (CGFloat) -> Void

    func makeUIViewController(context: Context) -> ReadableContentWidthMeasurementController {
        let controller = ReadableContentWidthMeasurementController()
        controller.viewRespectsSystemMinimumLayoutMargins = includeLayoutMargins
        controller.onWidthChange = onWidthChange
        return controller
    }

    func updateUIViewController(_ controller: ReadableContentWidthMeasurementController, context: Context) {
        controller.onWidthChange = onWidthChange
        controller.viewRespectsSystemMinimumLayoutMargins = includeLayoutMargins
        controller.traitOverrides.preferredContentSizeCategory = UIContentSizeCategory(context.environment.dynamicTypeSize)
        controller.view.setNeedsLayout()
    }

    static func dismantleUIViewController(_ controller: ReadableContentWidthMeasurementController, coordinator: ()) {
        controller.stopReportingWidth()
    }
}
