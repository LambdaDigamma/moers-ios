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
        bannerTitle: String = "Update available",
        bannerMessage: String = "A newer version is available in the App Store.",
        updateButtonTitle: String = "Update",
        closeButtonTitle: String = "Close",
        sheetTitle: String = "Update recommended",
        sheetSubtitle: String = "Please install the latest version from the App Store.",
        sheetBody: String = "This version may no longer support all current app features.",
        sheetRequiredFooter: String = "The app can be used again after the update is installed."
    ) {
        self.bannerTitle = bannerTitle
        self.bannerMessage = bannerMessage
        self.updateButtonTitle = updateButtonTitle
        self.closeButtonTitle = closeButtonTitle
        self.sheetTitle = sheetTitle
        self.sheetSubtitle = sheetSubtitle
        self.sheetBody = sheetBody
        self.sheetRequiredFooter = sheetRequiredFooter
    }
}

