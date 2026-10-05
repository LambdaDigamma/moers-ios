import UIKit

final class MapPanelPassthroughView: UIView {
    
    weak var trackedView: UIView?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let trackedView else { return false }
        let convertedPoint = convert(point, to: trackedView)
        return trackedView.point(inside: convertedPoint, with: event)
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
