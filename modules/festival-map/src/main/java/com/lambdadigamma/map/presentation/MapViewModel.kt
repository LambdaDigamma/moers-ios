package com.lambdadigamma.map.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.map.data.model.FestivalMapFeature
import com.lambdadigamma.map.data.repository.FestivalMapRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

@HiltViewModel
internal class MapViewModel @Inject constructor(
    private val repository: FestivalMapRepository,
) : ViewModel() {

    private val updateMutex = Mutex()

    private val _uiState = MutableStateFlow(MapUiState(isLoading = true))
    val uiState: StateFlow<MapUiState> = _uiState.asStateFlow()

    init {
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
            is MapIntent.SelectFeature -> {
                _uiState.update { it.copy(selectedFeature = intent.feature) }
            }
            is MapIntent.ClearSelection -> {
                _uiState.update { it.copy(selectedFeature = null) }
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
                            selectedFeature = previousState.selectedFeature.retainIn(layers),
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
                )
            }

            val refreshResult = repository.refreshLayers(force)
            val layersResult = runCatching { repository.loadLayers() }

            _uiState.update { previousState ->
                val layers = layersResult.getOrElse { previousState.layers }
                previousState.copy(
                    layers = layers,
                    selectedFeature = previousState.selectedFeature.retainIn(layers),
                    isLoading = false,
                    isRefreshing = false,
                    refreshError = refreshResult.exceptionOrNull()
                        ?: layersResult.exceptionOrNull(),
                )
            }
        }
    }

    private fun FestivalMapFeature?.retainIn(
        layers: List<com.lambdadigamma.map.data.model.FestivalMapLayer>,
    ): FestivalMapFeature? {
        val selectedFeature = this ?: return null

        return layers
            .flatMap { it.features }
            .firstOrNull { it.id == selectedFeature.id }
    }
}
