import Core
import FactoryKit
import SwiftUI
import OSLog
import Combine

@Observable
class PreviewListEventsViewModel: StandardViewModel {

    var events: [EventListItemViewModel] = []

    private let repository: EventRepository
    private let logger = Logger(.coreUi)

    init(repository: EventRepository = Container.shared.eventRepository()) {
        self.repository = repository
        super.init()
    }

    public func setupObserver() {

        guard cancellables.isEmpty else { return }

        repository.events()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { [weak self] (completion: Subscribers.Completion<Error>) in

                if case .failure(let error) = completion {
                    self?.logger.error("\(String(describing: error))")
                }

            } receiveValue: { [weak self] (events: [Event]) in

                self?.events = events
                    .filter {
                        let createdAt = $0.createdAt ?? Date()
                        return createdAt.formatted(.dateTime.year()) == Date().formatted(.dateTime.year())
                    }
                    .map {
                        return EventListItemViewModel(
                            eventID: $0.id,
                            title: $0.name,
                            startDate: $0.startDate,
                            endDate: $0.endDate,
                            location: $0.place?.name,
                            media: $0.headerMedia,
                            isOpenEnd: $0.extras?.openEnd ?? false,
                            scheduleDisplayMode: $0.scheduleDisplayMode
                        )
                    }

            }
            .store(in: &cancellables)

    }

    // MARK: - Actions

    public func reload() async {
        guard !Task.isCancelled else { return }
        setupObserver()

        do {
            try await repository.reloadEvents()
        } catch {
            self.logger.error("\(error.debugDescription)")
        }

    }

    public func refresh() async {
        setupObserver()
        do {
            try await repository.refreshEvents()
        } catch {
            logger.error("\(error.debugDescription)")
        }
    }

    func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
