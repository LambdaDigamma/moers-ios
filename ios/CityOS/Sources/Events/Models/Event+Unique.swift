nonisolated public extension Event {
    static func unique(_ events: [Event]) -> [Event] {
        var identifiers: Set<ID> = []
        return events.filter { identifiers.insert($0.id).inserted }
    }
}
