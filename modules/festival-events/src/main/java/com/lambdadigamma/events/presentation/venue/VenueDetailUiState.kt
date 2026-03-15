package com.lambdadigamma.events.presentation.venue

import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import com.lambdadigamma.pages.data.remote.model.PageBlock

data class VenueDetailUiState(
    val isLoading: Boolean = false,
    val place: PlaceDisplayable? = null,
    val events: List<EventDisplayable> = emptyList(),
    val blocks: List<PageBlock> = emptyList(),
    val isError: Throwable? = null,
)
