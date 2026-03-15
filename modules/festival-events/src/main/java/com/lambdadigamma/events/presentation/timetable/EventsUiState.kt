package com.lambdadigamma.events.presentation.timetable

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import kotlinx.parcelize.Parcelize

@Immutable
@Parcelize
data class EventsUiState(
    val isLoading: Boolean = false,
    val events: List<EventDisplayable> = emptyList(),
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        object Loading : PartialState()

        data class Fetched(val list: List<EventDisplayable>) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
