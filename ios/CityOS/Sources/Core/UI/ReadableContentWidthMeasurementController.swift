import UIKit

final class ReadableContentWidthMeasurementController: UIViewController {
    var onWidthChange: ((CGFloat) -> Void)?
    private var pendingWidth: CGFloat?
    private var reportedWidth: CGFloat?
    private var deliveryIsPending = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        registerForTraitChanges([
            UITraitHorizontalSizeClass.self,
            UITraitVerticalSizeClass.self,
            UITraitPreferredContentSizeCategory.self,
            UITraitLayoutDirection.self,
        ]) { (self: ReadableContentWidthMeasurementController, _) in
            self.view.setNeedsLayout()
        }
    }

    func stopReportingWidth() {
        onWidthChange = nil
        pendingWidth = nil
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.readableContentGuide.layoutFrame.width
        guard width.isFinite, width > 0 else {
            pendingWidth = nil
            return
        }
        pendingWidth = width
        guard width != reportedWidth else { return }
        guard !deliveryIsPending else { return }
        deliveryIsPending = true
        // UIKit can lay out during a SwiftUI update. Deliver only the latest size later.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.deliveryIsPending = false
            guard self.view.window != nil, let width = self.pendingWidth else { return }
            self.pendingWidth = nil
            guard width != self.reportedWidth else { return }
            self.reportedWidth = width
            self.onWidthChange?(width)
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
