package com.lambdadigamma.parking.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.map
import com.lambdadigamma.core.Resource
import com.lambdadigamma.parking.ParkingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ParkingDashboardViewModel @Inject constructor(
    private val parkingRepository: ParkingRepository
) : ViewModel() {

    fun load(): LiveData<Resource<List<ParkingAreaDashboardUiState>>> {
        return parkingRepository.load().map { resource ->
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