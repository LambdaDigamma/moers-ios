#if DEBUG
import AppScaffold
import SwiftUI

// Keep the tab shell preview separate from startup refresh and onboarding.
private final class AppTabBarControllerPreview: AppTabBarController {
    override func viewWillAppear(_ animated: Bool) {}

    override func viewDidAppear(_ animated: Bool) {}
}

#Preview("City tabs") {
    AppTabBarControllerPreview(firstLaunch: FirstLaunch(
        getWasLaunchedBefore: { true },
        setWasLaunchedBefore: { _ in }
    ))
}
#endif
