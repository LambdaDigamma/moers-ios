package com.lambdadigamma.map.presentation

import android.os.Parcelable
import com.lambdadigamma.events.presentation.detail.EventDetailDisplayable
import kotlinx.parcelize.Parcelize

@Parcelize
data class MapUiState(
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
