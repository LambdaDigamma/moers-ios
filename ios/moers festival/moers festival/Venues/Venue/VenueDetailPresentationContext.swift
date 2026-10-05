import UIKit

public enum VenueDetailPresentationContext: Equatable {
    case automatic
    case phoneFullScreen
    case ipadDetail

    public static func current(for traitCollection: UITraitCollection) -> Self {
        traitCollection.horizontalSizeClass == .regular ? .ipadDetail : .phoneFullScreen
    }
}
