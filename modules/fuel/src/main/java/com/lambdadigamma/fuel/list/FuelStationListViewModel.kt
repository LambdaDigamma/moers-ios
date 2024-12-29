package com.lambdadigamma.fuel.list

import androidx.lifecycle.*
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.geo.LocationService
import com.lambdadigamma.core.geo.toPoint
import com.lambdadigamma.fuel.data.FuelRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class FuelStationListViewModel @Inject constructor(
    private val fuelRepository: FuelRepository,
    private val locationService: LocationService
) : ViewModel() {

    val fuelType = fuelRepository.fuelType.asLiveData(viewModelScope.coroutineContext)

    private val _fuelStations = MutableLiveData<Resource<List<FuelStationUiState>>>()
    val fuelStations: LiveData<Resource<List<FuelStationUiState>>> get() = _fuelStations

    fun reload() {

        viewModelScope.launch {

            val point = locationService.awaitLastLocation().toPoint()

            fuelRepository
                .getFuelStationList(point)
                .collect { _fuelStations.value = it }
        }

    }

}