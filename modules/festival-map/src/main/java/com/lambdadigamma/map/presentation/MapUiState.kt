package com.lambdadigamma.map.presentation

import com.lambdadigamma.events.presentation.EventDisplayable

internal data class MapUiState(
    val layers: List<com.lambdadigamma.map.data.model.FestivalMapLayer> = emptyList(),
    val places: List<com.lambdadigamma.map.data.model.FestivalMapPlace> = emptyList(),
    val selection: MapSelection? = null,
    val placeEvents: List<EventDisplayable> = emptyList(),
    val isLoadingEvents: Boolean = false,
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val refreshError: Throwable? = null,
)
