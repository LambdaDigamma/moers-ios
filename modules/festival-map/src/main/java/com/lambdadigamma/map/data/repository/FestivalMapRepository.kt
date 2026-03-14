package com.lambdadigamma.map.data.repository

import com.lambdadigamma.map.data.FestivalMapGeoJsonParser
import com.lambdadigamma.map.data.model.FestivalMapLayer
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.data.source.FestivalMapAssetSource
import com.lambdadigamma.map.data.source.FestivalMapCacheSource
import com.lambdadigamma.map.data.source.FestivalMapRefreshTracker
import com.lambdadigamma.map.data.source.FestivalMapRemoteSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject

internal interface FestivalMapRepository {
    suspend fun loadLayers(): List<FestivalMapLayer>

    suspend fun refreshLayers(force: Boolean = false): Result<Unit>
}

internal class DefaultFestivalMapRepository @Inject constructor(
    private val assetSource: FestivalMapAssetSource,
    private val cacheSource: FestivalMapCacheSource,
    private val refreshTracker: FestivalMapRefreshTracker,
    private val remoteSource: FestivalMapRemoteSource,
    private val parser: FestivalMapGeoJsonParser,
) : FestivalMapRepository {

    override suspend fun loadLayers(): List<FestivalMapLayer> = withContext(Dispatchers.IO) {
        FestivalMapLayerType.ordered.map(::loadLayer)
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
