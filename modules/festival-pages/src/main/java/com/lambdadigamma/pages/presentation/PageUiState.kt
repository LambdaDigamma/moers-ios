package com.lambdadigamma.pages.presentation

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import kotlinx.parcelize.Parcelize

@Immutable
@Parcelize
data class PageUiState(
    val isLoading: Boolean = false,
//    val event: EventDetailDisplayable? = null,
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        object Loading : PartialState()

//        data class Fetched(val event: EventDetailDisplayable) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
