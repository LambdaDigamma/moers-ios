import Events
import Observation

@Observable
final class UserScheduleFilter {
    @ObservationIgnored @PersistedFilter(key: "favoritesFilter") private var persistedFilter: EventFilter

    var value: EventFilter {
        get {
            access(keyPath: \.value)
            return persistedFilter
        }
        set {
            guard newValue != persistedFilter else { return }
            withMutation(keyPath: \.value) {
                persistedFilter = newValue
            }
        }
    }

    nonisolated deinit {}
}
