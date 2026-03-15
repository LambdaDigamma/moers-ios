package com.lambdadigamma.news.presentation.detail

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.news.presentation.PostDisplayable
import kotlinx.parcelize.Parcelize

@Immutable
@Parcelize
data class PostDetailUiState(
    val isLoading: Boolean = false,
    val post: PostDisplayable? = null,
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        data object Loading : PartialState()

        data class Fetched(val post: PostDisplayable) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
