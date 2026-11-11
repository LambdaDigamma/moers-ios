package com.lambdadigamma.parking

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ParkingUiState(
    val parkingAreas: List<ParkingArea> = emptyList(),
    val isLoading: Boolean = true,
    val isRefreshing: Boolean = false,
    val failed: Boolean = false,
) {
    val isOutdated: Boolean get() = parkingAreas.isOutdated()
}

/** Loads the parking areas for the dashboard card and the list. */
@HiltViewModel
class ParkingViewModel @Inject constructor(
    private val parkingRepository: ParkingRepository,
) : ViewModel() {

    private val _uiState = MutableStateFlow(ParkingUiState())
    val uiState: StateFlow<ParkingUiState> = _uiState.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        if (_uiState.value.isRefreshing) return
        viewModelScope.launch {
            _uiState.update { it.copy(isRefreshing = true) }
            val result = parkingRepository.parkingAreas()
            _uiState.update { state ->
                state.copy(
                    parkingAreas = result.getOrDefault(state.parkingAreas),
                    isLoading = false,
                    isRefreshing = false,
                    failed = result.isFailure,
                )
            }
        }
    }
}
