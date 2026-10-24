import UIKit

class TabSheetPresentationController: UISheetPresentationController {
    // UIKit keeps the sheet in the map's presentation context and owns its container.
    override var shouldPresentInFullscreen: Bool { false }
    override var shouldRemovePresentersView: Bool { false }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
