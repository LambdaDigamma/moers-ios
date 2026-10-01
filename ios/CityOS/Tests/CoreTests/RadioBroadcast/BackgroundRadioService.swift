import Combine
import Foundation
@testable import Core

final class BackgroundRadioService: RadioServiceProtocol {

    private let broadcasts: [RadioBroadcast]

    init(broadcasts: [RadioBroadcast]) {
        self.broadcasts = broadcasts
    }

    func load() -> AnyPublisher<[RadioBroadcast], Error> {
        Just(broadcasts)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .eraseToAnyPublisher()
    }

}
