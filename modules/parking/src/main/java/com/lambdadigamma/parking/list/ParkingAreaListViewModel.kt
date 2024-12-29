package com.lambdadigamma.parking.list

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.map
import com.lambdadigamma.core.Resource
import com.lambdadigamma.parking.ParkingAreaOpeningState
import com.lambdadigamma.parking.ParkingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import java.util.*
import javax.inject.Inject

data class ParkingAreaListItem(
    val id: Int,
    val name: String,
    val occupiedSites: Int,
    val capacity: Int,
    val currentOpeningState: ParkingAreaOpeningState,
    val lastUpdated: Date
)

@HiltViewModel
class ParkingAreaListViewModel @Inject constructor(
    private val parkingRepository: ParkingRepository
) : ViewModel() {

    fun load(): LiveData<Resource<List<ParkingAreaListItem>>> {
        return parkingRepository.loadParkingAreas().map { resource ->
            resource.transform { parkingAreas ->
                parkingAreas.map {
                    ParkingAreaListItem(
                        id = it.id,
                        name = it.name,
                        occupiedSites = it.occupiedSites,
                        capacity = it.capacity,
                        currentOpeningState = it.currentOpeningState,
                        lastUpdated = it.updatedAt ?: Date()
                    )
                }
            }
        }
    }

}