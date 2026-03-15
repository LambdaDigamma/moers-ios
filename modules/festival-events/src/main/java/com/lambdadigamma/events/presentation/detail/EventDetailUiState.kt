package com.lambdadigamma.events.presentation.detail

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import kotlinx.parcelize.Parcelize

@Immutable
@Parcelize
data class EventDetailUiState(
    val isLoading: Boolean = false,
    val event: EventDetailDisplayable? = null,
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        data object Loading : PartialState()

        data class Fetched(val event: EventDetailDisplayable) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
