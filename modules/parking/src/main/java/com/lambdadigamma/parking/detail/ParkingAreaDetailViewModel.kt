package com.lambdadigamma.parking.detail

import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.lambdadigamma.core.Resource
import com.lambdadigamma.parking.ParkingService
import dagger.hilt.android.lifecycle.HiltViewModel
import java.util.*
import javax.inject.Inject

@HiltViewModel
class ParkingAreaDetailViewModel @Inject constructor(
    private val parkingAreaService: ParkingService
) : ViewModel() {

    private var currentParkingAreaId: Int? = null

    fun load(id: Int): LiveData<Resource<ParkingAreaDetailState>> {
        this.currentParkingAreaId = id

        return Transformations.map(parkingAreaService.getParkingArea(id)) { resource ->
            return@map resource.transform { response ->
                val parkingArea = response.data.parkingArea
                return@transform ParkingAreaDetailState(
                    id = parkingArea.id,
                    name = parkingArea.name,
                    location = parkingArea.location,
                    currentOpeningState = parkingArea.currentOpeningState,
                    capacity = parkingArea.capacity,
                    occupiedSites = parkingArea.occupiedSites,
                    freeSites = parkingArea.capacity - parkingArea.occupiedSites,
                    occupancy = listOf<Occupancy>(), // response.data.pastOccupancy.data.data.data,
                    lastUpdated = parkingArea.updatedAt ?: Date()
                )
            }
        }
    }

}