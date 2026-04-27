package com.lambdadigamma.events.presentation.timetable

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.filter.EventFilter
import com.lambdadigamma.events.presentation.filter.EventVenueFilterOption
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class TimetableData(
    val sections: List<TimetableSection> = emptyList(),
    val currentIndex: Int,
    val filter: EventFilter = EventFilter(),
    val availableVenues: List<EventVenueFilterOption> = emptyList(),
    val hasAnyEvents: Boolean = false,
    val isFilterSheetVisible: Boolean = false,
): Parcelable

@Parcelize
data class TimetableSection(
    val range: Pair<Date, Date>? = null,
    val events: List<EventDisplayable>,
    val isUndated: Boolean = false,
): Parcelable

@Immutable
@Parcelize
data class TimetableUiState(
    val isLoading: Boolean = false,
    val data: TimetableData = TimetableData(currentIndex = 0),
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        object Loading : PartialState()

        data class Fetched(
            val data: TimetableData
        ) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()

        data class FilterSheetVisibilityChanged(val isVisible: Boolean) : PartialState()
    }
}
