import SwiftUI
import Events

struct EventFilterSheetWrapper: View {
    @Bindable var model: UserScheduleFilter
    let isFavoritesFilterEnabled: Bool
    
    var body: some View {
        EventFilterSheet(
            filter: $model.value,
            isFavoritesFilterEnabled: isFavoritesFilterEnabled
        )
    }
}

#Preview {
    EventFilterSheetWrapper(
        model: UserScheduleFilter(),
        isFavoritesFilterEnabled: false
    )
}
