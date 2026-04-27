package com.lambdadigamma.map.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.geo.LocationUpdatesUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.map.data.model.FestivalMapLayer
import com.lambdadigamma.map.data.model.FestivalMapPlace
import com.lambdadigamma.map.data.repository.FestivalMapRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import javax.inject.Inject

@HiltViewModel
internal class MapViewModel @Inject constructor(
    private val repository: FestivalMapRepository,
    private val refreshEventsUseCase: RefreshEventsUseCase,
    private val locationUpdatesUseCase: LocationUpdatesUseCase,
) : ViewModel() {

    private val updateMutex = Mutex()
    private var hasRequestedPlacesRefresh = false

    private val _uiState = MutableStateFlow(MapUiState(isLoading = true))
    val uiState: StateFlow<MapUiState> = _uiState.asStateFlow()

    init {
        observePlaces()
        viewModelScope.launch {
            loadLayers()
            refreshLayers(force = false)
        }
    }

    fun acceptIntent(intent: MapIntent) {
        when (intent) {
            is MapIntent.Load -> {
                viewModelScope.launch {
                    loadLayers()
                }
            }
            is MapIntent.Refresh -> {
                viewModelScope.launch {
                    refreshLayers(force = true)
                }
            }
            is MapIntent.CenterOnUserLocation -> {
                viewModelScope.launch {
                    centerOnUserLocation()
                }
            }
            is MapIntent.SelectFeature -> {
                _uiState.update {
                    it.copy(
                        selection = MapSelection.Feature(intent.feature),
                        locationError = null,
                    )
                }
            }
            is MapIntent.SelectPlace -> {
                _uiState.update {
                    it.copy(
                        selection = MapSelection.Place(intent.place),
                        locationError = null,
                    )
                }
            }
            is MapIntent.ClearSelection -> {
                _uiState.update {
                    it.copy(
                        selection = null,
                        locationError = null,
                    )
                }
            }
        }
    }

    private suspend fun loadLayers() {
        updateMutex.withLock {
            _uiState.update {
                it.copy(
                    isLoading = true,
                )
            }

            runCatching { repository.loadLayers() }
                .onSuccess { layers ->
                    _uiState.update { previousState ->
                        previousState.copy(
                            layers = layers,
                            selection = previousState.selection.retainIn(
                                layers = layers,
                                places = previousState.places,
                            ),
                            isLoading = false,
                        )
                    }
                }
                .onFailure { throwable ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            refreshError = throwable,
                        )
                    }
                }
        }
    }

    private suspend fun refreshLayers(force: Boolean) {
        updateMutex.withLock {
            _uiState.update {
                it.copy(
                    isRefreshing = true,
                    refreshError = null,
                    locationError = null,
                )
            }

            val refreshResult = repository.refreshLayers(force)
            val eventsRefreshResult = if (force) {
                refreshEventsUseCase()
            } else {
                Result.success(Unit)
            }
            val layersResult = runCatching { repository.loadLayers() }

            _uiState.update { previousState ->
                val layers = layersResult.getOrElse { previousState.layers }
                previousState.copy(
                    layers = layers,
                    selection = previousState.selection.retainIn(
                        layers = layers,
                        places = previousState.places,
                    ),
                    isLoading = false,
                    isRefreshing = false,
                    refreshError = refreshResult.exceptionOrNull()
                        ?: eventsRefreshResult.exceptionOrNull()
                        ?: layersResult.exceptionOrNull(),
                )
            }
        }
    }

    private suspend fun centerOnUserLocation() {
        _uiState.update {
            it.copy(
                isLocatingUser = true,
                locationError = null,
            )
        }

        runCatching {
            locationUpdatesUseCase.fetchCurrentLocation().firstOrNull()
                ?: error("Unable to determine your location right now.")
        }.onSuccess { point ->
            _uiState.update {
                it.copy(
                    isLocatingUser = false,
                    userLocation = point,
                    userLocationFocusToken = it.userLocationFocusToken + 1,
                )
            }
        }.onFailure { throwable ->
            _uiState.update {
                it.copy(
                    isLocatingUser = false,
                    locationError = throwable,
                )
            }
        }
    }

    private fun observePlaces() {
        viewModelScope.launch {
            repository.observePlaces()
                .catch { throwable ->
                    _uiState.update { it.copy(refreshError = throwable) }
                }
                .collect { places ->
                    _uiState.update { previousState ->
                        previousState.copy(
                            places = places,
                            selection = previousState.selection.retainIn(
                                layers = previousState.layers,
                                places = places,
                            ),
                        )
                    }

                    if (places.isEmpty() && !hasRequestedPlacesRefresh) {
                        hasRequestedPlacesRefresh = true
                        refreshEventsUseCase()
                            .onFailure { throwable ->
                                _uiState.update { it.copy(refreshError = throwable) }
                            }
                    }
                }
        }
    }

    private fun MapSelection?.retainIn(
        layers: List<FestivalMapLayer>,
        places: List<FestivalMapPlace>,
    ): MapSelection? {
        return when (val selection = this) {
            null -> null
            is MapSelection.Feature -> {
                layers
                    .flatMap(FestivalMapLayer::features)
                    .firstOrNull { it.id == selection.value.id }
                    ?.let(MapSelection::Feature)
            }
            is MapSelection.Place -> {
                places
                    .firstOrNull { it.id == selection.value.id }
                    ?.let(MapSelection::Place)
            }
        }
    }
}
