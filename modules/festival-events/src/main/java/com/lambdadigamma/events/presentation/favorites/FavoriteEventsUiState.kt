package com.lambdadigamma.events.presentation.favorites

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.filter.EventFilter
import com.lambdadigamma.events.presentation.filter.EventVenueFilterOption
import kotlinx.parcelize.Parcelize
import java.util.Date

typealias FavoriteEventsFilter = EventFilter
typealias FavoriteVenueFilterOption = EventVenueFilterOption

@Parcelize
data class FavoriteEventsData(
    val sections: List<FavoriteEventsSection> = emptyList(),
    val currentIndex: Int = 0,
    val filter: FavoriteEventsFilter = FavoriteEventsFilter(),
    val availableVenues: List<FavoriteVenueFilterOption> = emptyList(),
    val hasAnyFavorites: Boolean = false,
    val isFilterSheetVisible: Boolean = false,
): Parcelable

@Parcelize
data class FavoriteEventsSection(
    val range: Pair<Date, Date>? = null,
    val events: List<EventDisplayable>,
    val isUndated: Boolean = false,
): Parcelable

@Immutable
@Parcelize
data class FavoriteEventsUiState(
    val isLoading: Boolean = false,
    val data: FavoriteEventsData = FavoriteEventsData(),
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        object Loading : PartialState()

        data class Fetched(
            val data: FavoriteEventsData
        ) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()

        data class FilterSheetVisibilityChanged(val isVisible: Boolean) : PartialState()
    }
}
