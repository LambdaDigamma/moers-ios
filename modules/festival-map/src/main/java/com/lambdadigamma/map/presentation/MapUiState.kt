package com.lambdadigamma.map.presentation

import com.lambdadigamma.core.geo.Point

internal data class MapUiState(
    val layers: List<com.lambdadigamma.map.data.model.FestivalMapLayer> = emptyList(),
    val places: List<com.lambdadigamma.map.data.model.FestivalMapPlace> = emptyList(),
    val selection: MapSelection? = null,
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val refreshError: Throwable? = null,
    val isLocatingUser: Boolean = false,
    val userLocation: Point? = null,
    val userLocationFocusToken: Long = 0,
    val locationError: Throwable? = null,
)
