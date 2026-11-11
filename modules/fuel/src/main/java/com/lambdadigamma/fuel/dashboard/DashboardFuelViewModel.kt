package com.lambdadigamma.fuel.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.geo.LocationService
import com.lambdadigamma.fuel.data.FuelRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class DashboardFuelViewModel @Inject constructor(
    private val fuelRepository: FuelRepository,
    private val locationService: LocationService,
) : ViewModel() {

    private val _dashboardData = MutableLiveData<Resource<FuelDashboardData>>()
    val dashboardData: LiveData<Resource<FuelDashboardData>> get() = _dashboardData

    /** Loads prices near the device, or in the centre of Moers without a location. */
    fun load() {
        viewModelScope.launch {
            val point = locationService.currentLocation() ?: FuelRepository.moersCenter
            fuelRepository
                .getDashboardData(point)
                .collect { _dashboardData.value = it }
        }
    }
}
