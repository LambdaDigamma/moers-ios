package com.lambdadigamma.events.presentation.search

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import kotlinx.parcelize.Parcelize

@Immutable
@Parcelize
data class EventSearchUiState(
    val isLoading: Boolean = false,
    val query: String = "",
    val sections: List<EventSearchSection> = emptyList(),
    val isError: Throwable? = null,
) : Parcelable
