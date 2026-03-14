package com.lambdadigamma.map.presentation

internal data class MapUiState(
    val layers: List<com.lambdadigamma.map.data.model.FestivalMapLayer> = emptyList(),
    val places: List<com.lambdadigamma.map.data.model.FestivalMapPlace> = emptyList(),
    val selection: MapSelection? = null,
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val refreshError: Throwable? = null,
)
