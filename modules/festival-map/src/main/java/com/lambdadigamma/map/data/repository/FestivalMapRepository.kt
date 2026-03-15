package com.lambdadigamma.map.data.repository

import com.lambdadigamma.events.data.local.dao.PlaceDao
import com.lambdadigamma.events.data.local.model.PlaceCached
import com.lambdadigamma.map.data.FestivalMapGeoJsonParser
import com.lambdadigamma.map.data.model.FestivalMapLayer
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.data.model.FestivalMapPlace
import com.lambdadigamma.map.data.source.FestivalMapAssetSource
import com.lambdadigamma.map.data.source.FestivalMapCacheSource
import com.lambdadigamma.map.data.source.FestivalMapRefreshTracker
import com.lambdadigamma.map.data.source.FestivalMapRemoteSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import java.time.Clock
import java.time.LocalDate
import javax.inject.Inject

internal interface FestivalMapRepository {
    suspend fun loadLayers(): List<FestivalMapLayer>

    fun observePlaces(): Flow<List<FestivalMapPlace>>

    suspend fun refreshLayers(force: Boolean = false): Result<Unit>
}

internal class DefaultFestivalMapRepository @Inject constructor(
    private val assetSource: FestivalMapAssetSource,
    private val cacheSource: FestivalMapCacheSource,
    private val refreshTracker: FestivalMapRefreshTracker,
    private val remoteSource: FestivalMapRemoteSource,
    private val parser: FestivalMapGeoJsonParser,
    private val placeDao: PlaceDao,
    private val clock: Clock = Clock.systemDefaultZone(),
) : FestivalMapRepository {

    override suspend fun loadLayers(): List<FestivalMapLayer> = withContext(Dispatchers.IO) {
        FestivalMapLayerType.ordered.map(::loadLayer)
    }

    override fun observePlaces(): Flow<List<FestivalMapPlace>> {
        return placeDao.getFestivalPlaces(currentFestivalCollection(clock))
            .map { places ->
                places.map(PlaceCached::toFestivalMapPlace)
            }
    }

    override suspend fun refreshLayers(force: Boolean): Result<Unit> = withContext(Dispatchers.IO) {
        var firstFailure: Throwable? = null

        FestivalMapLayerType.ordered.forEach { layerType ->
            if (!force && !refreshTracker.shouldRefresh(layerType, ttlMinutes = REFRESH_TTL_MINUTES)) {
                return@forEach
            }

            remoteSource.fetchLayer(layerType)
                .onSuccess { rawJson ->
                    runCatching {
                        parser.parseLayer(layerType, rawJson)
                    }
                        .onSuccess {
                            cacheSource.writeLayer(layerType, rawJson)
                            refreshTracker.markRefreshed(layerType)
                        }
                        .onFailure { throwable ->
                            if (firstFailure == null) {
                                firstFailure = throwable
                            }
                        }
                }
                .onFailure { throwable ->
                    if (firstFailure == null) {
                        firstFailure = throwable
                    }
                }
        }

        firstFailure?.let(Result.Companion::failure) ?: Result.success(Unit)
    }

    private fun loadLayer(type: FestivalMapLayerType): FestivalMapLayer {
        val cachedLayer = cacheSource
            .readLayer(type)
            ?.let { rawJson ->
                runCatching { parser.parseLayer(type, rawJson) }.getOrNull()
            }

        if (cachedLayer != null) {
            return cachedLayer
        }

        return parser.parseLayer(
            type = type,
            rawJson = assetSource.readLayer(type),
        )
    }

    private companion object {
        const val REFRESH_TTL_MINUTES = 120L
    }
}

internal fun currentFestivalCollection(clock: Clock): String {
    val year = LocalDate.now(clock).year % 100
    return "festival%02d".format(year)
}

private fun PlaceCached.toFestivalMapPlace(): FestivalMapPlace {
    return FestivalMapPlace(
        id = id,
        name = name,
        point = com.lambdadigamma.map.data.model.FestivalMapCoordinate(
            latitude = lat,
            longitude = lng,
        ),
        addressLine1 = listOfNotNull(streetName, streetNumber)
            .joinToString(separator = " ")
            .trim(),
        addressLine2 = listOfNotNull(postalCode, postalTown)
            .joinToString(separator = " ")
            .trim(),
    )
}
