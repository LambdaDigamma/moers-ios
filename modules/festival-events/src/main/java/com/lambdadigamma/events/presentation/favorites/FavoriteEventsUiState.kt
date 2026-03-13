package com.lambdadigamma.events.presentation.favorites

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class FavoriteEventsData(
    val sections: List<FavoriteEventsSection> = emptyList(),
    val currentIndex: Int,
): Parcelable

@Parcelize
data class FavoriteEventsSection(
    val range: Pair<Date, Date>,
    val events: List<EventDisplayable>,
): Parcelable

@Immutable
@Parcelize
data class FavoriteEventsUiState(
    val isLoading: Boolean = false,
    val data: FavoriteEventsData = FavoriteEventsData(currentIndex = 0),
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        object Loading : PartialState()

        data class Fetched(
            val data: FavoriteEventsData
        ) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
