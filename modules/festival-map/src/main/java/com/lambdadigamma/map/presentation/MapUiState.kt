package com.lambdadigamma.map.presentation

internal data class MapUiState(
    val layers: List<com.lambdadigamma.map.data.model.FestivalMapLayer> = emptyList(),
    val selectedFeature: com.lambdadigamma.map.data.model.FestivalMapFeature? = null,
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val refreshError: Throwable? = null,
)
