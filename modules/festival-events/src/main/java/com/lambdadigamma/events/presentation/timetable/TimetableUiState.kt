package com.lambdadigamma.events.presentation.timetable

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class TimetableData(
    val sections: List<TimetableSection> = emptyList(),
    val currentIndex: Int,
): Parcelable

@Parcelize
data class TimetableSection(
    val range: Pair<Date, Date>,
    val events: List<EventDisplayable>,
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
    }
}
