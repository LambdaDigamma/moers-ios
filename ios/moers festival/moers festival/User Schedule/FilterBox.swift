import Combine
import Events

final class FilterBox: ObservableObject {
    @Published var filter: EventFilter

    init(filter: EventFilter) {
        self.filter = filter
    }

    nonisolated deinit {}
}
