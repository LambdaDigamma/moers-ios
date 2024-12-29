package com.lambdadigamma.parking

import android.content.Context
import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import com.lambdadigamma.core.AppExecutors
import com.lambdadigamma.core.Resource
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

class ParkingRepository @Inject constructor(
    @ApplicationContext context: Context,
    private val parkingService: ParkingService,
//    private val eventDao: EventDao,
//    private val moersService: MeinMoersService,
    private val appExecutors: AppExecutors
) {

    fun load(): LiveData<Resource<List<ParkingArea>>> {
        return Transformations.map(parkingService.getParkingDashboard()) {
            it.transform { response -> response.data.parkingAreas }
        }
    }

    fun loadParkingAreas(): LiveData<Resource<List<ParkingArea>>> {
        return Transformations.map(parkingService.getParkingAreas()) {
            it.transform { response -> response.data.parkingAreas }
        }
    }

}