import Foundation

nonisolated public enum EventPresentation {
    public static func location(for event: Event) -> String? {
        guard let location = event.displayLocationName else { return nil }
        guard let city = event.extras?.place?.trimmingCharacters(in: .whitespacesAndNewlines),
              !city.isEmpty else { return location }
        let name = normalized(location)
        let normalizedCity = normalized(city)
        if name == normalizedCity || name.hasSuffix(" " + normalizedCity) || name.hasSuffix("," + normalizedCity) {
            return location
        }
        return "\(location), \(city)"
    }

    public static func editorialSubtitle(for event: Event) -> String? {
        if let subtitle = event.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !subtitle.isEmpty {
            return subtitle
        }
        guard let teaser = event.teaser?.trimmingCharacters(in: .whitespacesAndNewlines), !teaser.isEmpty else { return nil }
        let normalizer = EventSearchTextNormalizer()
        let description = (event.description ?? "").replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        let teaserText = teaser.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        guard !normalizer.normalize(description).hasPrefix(normalizer.normalize(teaserText)) else { return nil }
        return teaser
    }

    public static func dateRange(
        for event: Event,
        calendar: Calendar = .autoupdatingCurrent,
        locale: Locale = .autoupdatingCurrent
    ) -> String? {
        guard event.showsDateComponent, let startDate = event.startDate else { return nil }
        if !event.showsTimeComponent {
            return dateString(startDate, template: "EddMM", calendar: calendar, locale: locale)
        }
        let start = dateString(startDate, template: "EddMMjm", calendar: calendar, locale: locale)
        guard let endDate = event.endDate else { return start }
        let template = calendar.isDate(startDate, inSameDayAs: endDate) ? "jm" : "EddMMjm"
        let end = dateString(endDate, template: template, calendar: calendar, locale: locale)
        return "\(start) – \(end)"
    }

    public static func dateString(
        _ date: Date,
        template: String,
        calendar: Calendar = .autoupdatingCurrent,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
