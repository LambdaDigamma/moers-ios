import Foundation

public struct AppUpdatePresentation: Equatable, Identifiable, Sendable {
    public let version: String?
    public let storeURL: URL
    public let allowsDismissal: Bool

    public var id: String {
        [
            version ?? "unknown",
            storeURL.absoluteString,
            allowsDismissal ? "dismissible" : "required"
        ].joined(separator: "|")
    }

    public init(version: String?, storeURL: URL, allowsDismissal: Bool) {
        self.version = version
        self.storeURL = storeURL
        self.allowsDismissal = allowsDismissal
    }
}

public struct AppUpdateCopy: Equatable, Sendable {
    public let bannerTitle: String
    public let bannerMessage: String
    public let updateButtonTitle: String
    public let closeButtonTitle: String
    public let sheetTitle: String
    public let sheetSubtitle: String
    public let sheetBody: String
    public let sheetRequiredFooter: String

    public init(
        bannerTitle: String? = nil,
        bannerMessage: String? = nil,
        updateButtonTitle: String? = nil,
        closeButtonTitle: String? = nil,
        sheetTitle: String? = nil,
        sheetSubtitle: String? = nil,
        sheetBody: String? = nil,
        sheetRequiredFooter: String? = nil
    ) {
        self.bannerTitle = bannerTitle ?? String(localized: "Update available", bundle: .module)
        self.bannerMessage = bannerMessage ?? String(localized: "A newer version is available in the App Store.", bundle: .module)
        self.updateButtonTitle = updateButtonTitle ?? String(localized: "Update", bundle: .module)
        self.closeButtonTitle = closeButtonTitle ?? String(localized: "Close", bundle: .module)
        self.sheetTitle = sheetTitle ?? String(localized: "Update recommended", bundle: .module)
        self.sheetSubtitle = sheetSubtitle ?? String(localized: "Please install the latest version from the App Store.", bundle: .module)
        self.sheetBody = sheetBody ?? String(localized: "This version may no longer support all current app features.", bundle: .module)
        self.sheetRequiredFooter = sheetRequiredFooter ?? String(localized: "The app can be used again after the update is installed.", bundle: .module)
    }
}

