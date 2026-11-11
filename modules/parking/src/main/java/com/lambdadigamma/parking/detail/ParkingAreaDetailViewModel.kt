package com.lambdadigamma.parking.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.parking.ParkingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface ParkingAreaDetailUiState {
    data object Loading : ParkingAreaDetailUiState
    data object Failed : ParkingAreaDetailUiState
    data class Loaded(val response: ParkingAreaResponse) : ParkingAreaDetailUiState
}

@HiltViewModel
class ParkingAreaDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val parkingRepository: ParkingRepository,
) : ViewModel() {

    private val id: Int = checkNotNull(savedStateHandle["id"])
    private val _uiState = MutableStateFlow<ParkingAreaDetailUiState>(ParkingAreaDetailUiState.Loading)
    val uiState: StateFlow<ParkingAreaDetailUiState> = _uiState.asStateFlow()

    init {
        load()
    }

    fun load() {
        viewModelScope.launch {
            _uiState.value = ParkingAreaDetailUiState.Loading
            _uiState.value = parkingRepository.parkingArea(id).fold(
                onSuccess = { ParkingAreaDetailUiState.Loaded(it) },
                onFailure = { ParkingAreaDetailUiState.Failed },
            )
        }
    }
}
