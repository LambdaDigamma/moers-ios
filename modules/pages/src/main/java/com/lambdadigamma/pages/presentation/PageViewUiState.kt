package com.lambdadigamma.pages.presentation

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import kotlinx.parcelize.Parcelize

@Immutable
@Parcelize
data class PageViewUiState(
    val isLoading: Boolean = false,
    val page: PageDisplayable? = null,
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        data object Loading : PartialState()

        data class Fetched(val page: PageDisplayable) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
