import UIKit

/// UIKit owns the sheet geometry and gestures within the Map tab's presentation context.
final class MapSheetPresentationController: UISheetPresentationController {
    static let compactDetent = UISheetPresentationController.Detent.Identifier("MapCompact")

    override var shouldPresentInFullscreen: Bool { false }
    override var shouldRemovePresentersView: Bool { false }

    nonisolated deinit {}
}
