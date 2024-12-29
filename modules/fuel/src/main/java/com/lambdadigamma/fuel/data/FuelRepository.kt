package com.lambdadigamma.fuel.data

import android.content.Context
import android.util.Log
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.geo.GeocodingService
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.toResource
import com.lambdadigamma.core.utils.dataStore
import com.lambdadigamma.fuel.R
import com.lambdadigamma.fuel.dashboard.FuelDashboardData
import com.lambdadigamma.fuel.list.FuelStationUiState
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.*
import javax.inject.Inject
import kotlin.math.roundToInt

const val FUEL_TYPE_KEY = "fuel_type"

data class FuelStationListResponse(
    val stations: List<FuelStationUiState>,
    val searchedType: FuelType
)


class FuelRepository @Inject constructor(
    @ApplicationContext private val context: Context,
    private val fuelService: FuelService,
    private val fuelDao: FuelDao,
    private val geocodingService: GeocodingService
) {
    private val dataStore: DataStore<Preferences> = context.dataStore

    @OptIn(FlowPreview::class)
    suspend fun getFuelStationList(
        point: Point
    ): Flow<Resource<List<FuelStationUiState>>> {
        return fuelType
            .flatMapConcat { fuelType ->
                getFuelStations(point, fuelType)
            }
            .map { it.transform { response -> response.stations } }
    }

    @OptIn(FlowPreview::class)
    suspend fun getDashboardData(
        point: Point
    ): Flow<Resource<FuelDashboardData>> {

        val locationTitle = geocodingService
            .reverseGeocode(point)
            .firstOrNull()
            ?.place
            ?: this.context.getString(R.string.fuel_dashboard_location_unknown)

        return fuelType
            .flatMapConcat { fuelType ->
                getFuelStations(point, fuelType)
            }
            .map { resource ->
                resource.transform { response ->

                    val average = calculateAverage(response.stations)

                    FuelDashboardData(
                        type = "L ${response.searchedType.localizedName().uppercase()}",
                        location = locationTitle,
                        price = average.first,
                        numberOfStations = average.second
                    )
                }
            }
            .flowOn(Dispatchers.IO)

    }

    val fuelType: Flow<FuelType> = dataStore.data
        .map { settings ->
            settings[fuelTypeKey]?.let {
                try {
                    FuelType.fromString(it)
                } catch (e: Exception) {
                    Log.e("FuelRepository", "Invalid fuel type: $it")
                    defaultFuelType
                }
            } ?: defaultFuelType
        }

    private suspend fun getFuelStations(
        point: Point,
        fuelType: FuelType
    ): Flow<Resource<FuelStationListResponse>> {
        return flow<Resource<List<FuelStation>>> {
            emit(Resource.success(fuelDao.getFuelStations()))
            emit(Resource.loading())

            val result = fuelService.getFuelStations(
                latitude = point.latitude,
                longitude = point.longitude,
                radius = 10.0,
                FuelSorting.DISTANCE.value,
                fuelType.apiValue()
            )

            val resource = result.toResource()
                .transform { response ->
                    response.stations.orEmpty()
                }

            if (resource.isSuccessful()) {
                resource.data?.let { stations ->
                    fuelDao.deleteAllFuelStations()
                    fuelDao.insertFuelStations(stations)
                }
            }

            emit(resource)

        }.map { resource ->
            resource.transform { stations ->
                val uiStates = stations.map { station ->
                    FuelStationUiState(
                        id = station.id,
                        brand = station.brand.trim(),
                        name = station.name.trim(),
                        point = station.coordinate,
                        price = station.price ?: 0.0,
                        distance = station.dist
                    )
                }
                return@transform FuelStationListResponse(
                    stations = uiStates,
                    searchedType = fuelType
                )
            }
        }.flowOn(Dispatchers.IO)
    }

    fun getFuelStation(id: String): Flow<Resource<FuelStation>> {
        return flow<Resource<FuelStation>> {
            emit(Resource.success(fuelDao.getFuelStation(id)))
            emit(Resource.loading())

            val result = fuelService.getFuelStation(id)

            val resource = result.toResource()

            if (resource.isSuccessful()) {
                resource.data?.let { response ->
                    fuelDao.insertFuelStations(listOf(response.station))
                }
            }

            emit(resource.transform { response ->
                response.station
            })
        }.flowOn(Dispatchers.IO)
    }

    suspend fun updateFuelType(fuelType: FuelType) {
        dataStore.edit { preferences ->
            preferences[fuelTypeKey] = fuelType.value
        }
    }

    private fun calculateAverage(fuelStations: List<FuelStationUiState>): Pair<Double, Int> {

        val notNull = fuelStations.orEmpty().mapNotNull {
            it.price
        }

        val average = DoubleArray(notNull.size) { i ->
            notNull[i]
        }.average()

        val sanitizedAveragePrice =
            if (!average.isNaN()) (average * 100).roundToInt() / 100.0 else 0.0

        return Pair(sanitizedAveragePrice, notNull.size)

    }

    companion object {
        val fuelTypeKey = stringPreferencesKey(FUEL_TYPE_KEY)
        val defaultFuelType = FuelType.DIESEL
    }

}