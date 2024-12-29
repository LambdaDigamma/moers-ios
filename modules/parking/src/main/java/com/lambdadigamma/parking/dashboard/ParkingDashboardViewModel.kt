package com.lambdadigamma.parking.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.lambdadigamma.core.Resource
import com.lambdadigamma.parking.ParkingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ParkingDashboardViewModel @Inject constructor(
    private val parkingRepository: ParkingRepository
) : ViewModel() {

    fun load(): LiveData<Resource<List<ParkingAreaDashboardUiState>>> {
        return Transformations.map(parkingRepository.load()) { resource ->
            return@map resource.transform {
                it.map { parkingArea ->
                    ParkingAreaDashboardUiState(
                        id = parkingArea.id,
                        name = parkingArea.name,
                        freeSites = parkingArea.capacity - parkingArea.occupiedSites
                    )
                }
            }
        }
    }

}