import Core

nonisolated enum SearchDrawerItem: Hashable {
    case category(String)
    case location(Core.AnyLocation)
}
