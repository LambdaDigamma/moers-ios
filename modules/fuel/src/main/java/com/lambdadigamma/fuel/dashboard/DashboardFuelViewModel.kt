package com.lambdadigamma.fuel.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.geo.LocationService
import com.lambdadigamma.core.geo.toPoint
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

    fun load() {
        viewModelScope.launch {

            val location = locationService.awaitLastLocation()

            if (location != null) {
                val point = locationService.awaitLastLocation().toPoint()

                fuelRepository
                    .getDashboardData(point)
                    .collect { _dashboardData.value = it }
            }

        }
    }

}