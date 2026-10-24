
import SwiftUI
import Events

struct EventFilterSheetWrapper: View {
    @ObservedObject var box: FilterBox
    let isFavoritesFilterEnabled: Bool
    
    var body: some View {
        EventFilterSheet(
            filter: $box.filter,
            isFavoritesFilterEnabled: isFavoritesFilterEnabled
        )
    }
}
