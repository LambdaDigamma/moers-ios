package com.lambdadigamma.events.presentation.download

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.EventDetailDisplayable
import kotlinx.parcelize.Parcelize

@Immutable
@Parcelize
data class DownloadEventsUiState(
    val isLoading: Boolean = false,
    val events: List<EventDownloadDisplayable> = emptyList(),
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        object Loading : PartialState()

        data class Fetched(val events: List<EventDownloadDisplayable>) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
