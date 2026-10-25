import UIKit

@MainActor
final class SelectionFeedbackGeneratorSpy: UISelectionFeedbackGenerator {
    private(set) var selectionCount = 0
    private(set) var prepareCount = 0

    override func prepare() {
        prepareCount += 1
    }

    override func selectionChanged() {
        selectionCount += 1
    }

    @available(iOS 17.5, *)
    override func selectionChanged(at location: CGPoint) {
        selectionCount += 1
    }

    nonisolated deinit {}
}
