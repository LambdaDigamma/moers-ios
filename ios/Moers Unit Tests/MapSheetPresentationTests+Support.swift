import UIKit
import XCTest

extension MapSheetPresentationTests {
    func allSubviews(_ view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap(allSubviews)
    }

    func waitForCondition(file: StaticString = #filePath, line: UInt = #line, _ condition: () -> Bool) async {
        for _ in 0..<60 {
            // Layout must run while UIKit finishes a presentation or a trait change.
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(50))
        }
        XCTFail("The UIKit presentation did not reach the expected state.", file: file, line: line)
    }

    func makeWindow(
        _ controller: UIViewController,
        size: CGSize = CGSize(width: 402, height: 874),
        horizontalSizeClass: UIUserInterfaceSizeClass = .compact
    ) -> UIWindow {
        let window: UIWindow
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            window = UIWindow(windowScene: scene)
            window.frame = CGRect(origin: .zero, size: size)
        } else {
            window = UIWindow(frame: CGRect(origin: .zero, size: size))
        }
        controller.traitOverrides.horizontalSizeClass = horizontalSizeClass
        let tabs = UITabBarController()
        if #available(iOS 18.0, *) { tabs.mode = .tabBar }
        tabs.viewControllers = [controller]
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        controller.loadViewIfNeeded()
        window.layoutIfNeeded()
        return window
    }
}
