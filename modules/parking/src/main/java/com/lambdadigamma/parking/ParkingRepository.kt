package com.lambdadigamma.parking

import com.lambdadigamma.core.extensions.resultOf
import com.lambdadigamma.parking.detail.ParkingAreaResponse
import javax.inject.Inject

class ParkingRepository @Inject constructor(
    private val parkingService: ParkingService,
) {

    suspend fun parkingAreas(): Result<List<ParkingArea>> = resultOf {
        parkingService.getParkingAreas().data.parkingAreas.sortedBy { it.name }
    }

    suspend fun parkingArea(id: Int): Result<ParkingAreaResponse> = resultOf {
        parkingService.getParkingArea(id).data
    }

}
