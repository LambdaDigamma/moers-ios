import UIKit

final class MapSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    weak var sheetDelegate: UISheetPresentationControllerDelegate?
    var selectedDetentIdentifier = MapSheetPresentationController.compactDetent
    var compactHeightAdjustment: CGFloat = 0

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let sheet = MapSheetPresentationController(presentedViewController: presented, presenting: presenting)
        sheet.detents = [
            .custom(identifier: MapSheetPresentationController.compactDetent) { [weak self] context in
                min(128 + (self?.compactHeightAdjustment ?? 0), context.maximumDetentValue)
            },
            .medium(),
            .large()
        ]
        sheet.selectedDetentIdentifier = selectedDetentIdentifier
        sheet.largestUndimmedDetentIdentifier = .large
        sheet.prefersGrabberVisible = true
        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        sheet.delegate = sheetDelegate
        return sheet
    }

    nonisolated deinit {}
}
