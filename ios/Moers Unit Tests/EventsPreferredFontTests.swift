import UIKit
import XCTest
@testable import Moers

@MainActor
final class EventsPreferredFontTests: XCTestCase {
    func testWeightedFontsMatchSystemPreferredSizesAtNormalAndLargestText() async {
        for category in [UIContentSizeCategory.large, .accessibilityExtraExtraExtraLarge] {
            let traits = UITraitCollection(preferredContentSizeCategory: category)
            for style in [UIFont.TextStyle.footnote, .caption1, .caption2, .subheadline] {
                let font = UIFont.mmEventPreferredFont(forTextStyle: style, weight: .bold, compatibleWith: traits)
                let preferred = UIFont.preferredFont(forTextStyle: style, compatibleWith: traits)
                XCTAssertEqual(font.pointSize, preferred.pointSize, accuracy: 0.1, "\(category.rawValue), \(style.rawValue)")
                XCTAssertTrue(font.fontDescriptor.symbolicTraits.contains(.traitBold))
            }
        }
    }

    func testLabelCreatedAtLargestTextUsesOneAccessibilityScale() async throws {
        let traits = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        let controller = UIViewController()
        controller.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 800))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        let label = UILabel()
        controller.view.addSubview(label)
        controller.view.layoutIfNeeded()
        try await Task.sleep(for: .milliseconds(20))
        XCTAssertEqual(label.traitCollection.preferredContentSizeCategory, .accessibilityExtraExtraExtraLarge)
        label.text = "With Images"
        label.font = .mmEventPreferredFont(forTextStyle: .footnote, weight: .semibold, compatibleWith: label.traitCollection)
        label.adjustsFontForContentSizeCategory = true
        let preferred = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traits)

        XCTAssertEqual(label.font.pointSize, preferred.pointSize, accuracy: 0.1)
        XCTAssertEqual(label.intrinsicContentSize.height, ceil(preferred.lineHeight), accuracy: 1)

        // The previous helper used an already-scaled preferred size as its metrics base.
        let doubleScaled = UIFontMetrics(forTextStyle: .footnote).scaledFont(
            for: .systemFont(ofSize: preferred.pointSize, weight: .semibold),
            compatibleWith: traits
        )
        XCTAssertGreaterThan(doubleScaled.pointSize, label.font.pointSize)
    }

    func testDefaultFontMatchesTheSystemCategoryWithoutAnOverride() async {
        let font = UIFont.mmEventPreferredFont(forTextStyle: .footnote, weight: .semibold)
        XCTAssertEqual(font.pointSize, UIFont.preferredFont(forTextStyle: .footnote).pointSize, accuracy: 0.1)
    }

    func testHostedLabelFollowsTextSizeChangesAndKeepsItsWeight() async throws {
        let controller = UIViewController()
        controller.traitOverrides.preferredContentSizeCategory = .large
        let label = UILabel()
        label.text = "With Images"
        label.font = .mmEventPreferredFont(
            forTextStyle: .footnote,
            weight: .bold,
            compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
        )
        label.adjustsFontForContentSizeCategory = true
        label.frame = CGRect(x: 20, y: 20, width: 300, height: 200)
        controller.view.addSubview(label)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 800))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        for category in [UIContentSizeCategory.large, .accessibilityExtraExtraExtraLarge, .large] {
            controller.traitOverrides.preferredContentSizeCategory = category
            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(20))
            let traits = UITraitCollection(preferredContentSizeCategory: category)
            let preferred = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traits)
            XCTAssertEqual(label.font.pointSize, preferred.pointSize, accuracy: 0.1, category.rawValue)
            XCTAssertTrue(label.font.fontDescriptor.symbolicTraits.contains(.traitBold))
        }
    }
}
