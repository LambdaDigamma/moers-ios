package com.lambdadigamma.map.data.repository

import com.lambdadigamma.events.data.local.dao.PlaceDao
import com.lambdadigamma.events.data.local.model.PlaceCached
import com.lambdadigamma.map.data.FestivalMapGeoJsonParser
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.data.source.FestivalMapAssetSource
import com.lambdadigamma.map.data.source.FestivalMapCacheSource
import com.lambdadigamma.map.data.source.FestivalMapRefreshTracker
import com.lambdadigamma.map.data.source.FestivalMapRemoteSource
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOf
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class FestivalMapRepositoryTest {

    @Test
    fun `should prefer cached layer over bundled asset`() = kotlinx.coroutines.test.runTest {
        val assetSource = FakeFestivalMapAssetSource()
        val cacheSource = FakeFestivalMapCacheSource(
            values = mutableMapOf(
                FestivalMapLayerType.Surfaces to featureCollection("Cache"),
            ),
        )
        val objectUnderTest = createRepository(
            assetSource = assetSource,
            cacheSource = cacheSource,
        )

        val result = objectUnderTest.loadLayers()

        assertEquals("Cache", result.first().features.single().name)
    }

    @Test
    fun `should fall back to bundled asset when cache is missing`() = kotlinx.coroutines.test.runTest {
        val assetSource = FakeFestivalMapAssetSource(
            values = FestivalMapLayerType.ordered.associateWith { featureCollection("Bundled ${it.remoteKey}") },
        )
        val objectUnderTest = createRepository(
            assetSource = assetSource,
            cacheSource = FakeFestivalMapCacheSource(),
        )

        val result = objectUnderTest.loadLayers()

        assertEquals("Bundled surfaces", result.first().features.single().name)
    }

    @Test
    fun `should keep existing cached layer when remote refresh data is invalid`() = kotlinx.coroutines.test.runTest {
        val cacheSource = FakeFestivalMapCacheSource(
            values = mutableMapOf(
                FestivalMapLayerType.Surfaces to featureCollection("Cached"),
            ),
        )
        val remoteSource = FakeFestivalMapRemoteSource(
            values = mutableMapOf(
                FestivalMapLayerType.Surfaces to Result.success("{invalid"),
            ),
        )
        val objectUnderTest = createRepository(
            cacheSource = cacheSource,
            remoteSource = remoteSource,
        )

        val refreshResult = objectUnderTest.refreshLayers(force = true)
        val result = objectUnderTest.loadLayers()

        assertTrue(refreshResult.isFailure)
        assertEquals("Cached", result.first().features.single().name)
        assertEquals("Cached", cacheSource.values[FestivalMapLayerType.Surfaces]?.let(::extractName))
    }

    private fun createRepository(
        assetSource: FakeFestivalMapAssetSource = FakeFestivalMapAssetSource(),
        cacheSource: FakeFestivalMapCacheSource = FakeFestivalMapCacheSource(),
        remoteSource: FakeFestivalMapRemoteSource = FakeFestivalMapRemoteSource(),
    ): FestivalMapRepository {
        return DefaultFestivalMapRepository(
            assetSource = assetSource,
            cacheSource = cacheSource,
            refreshTracker = FakeFestivalMapRefreshTracker(),
            remoteSource = remoteSource,
            parser = FestivalMapGeoJsonParser(),
            placeDao = FakePlaceDao(),
        )
    }

    private fun featureCollection(name: String): String {
        return """
            {
              "type": "FeatureCollection",
              "features": [
                {
                  "type": "Feature",
                  "properties": {
                    "name": "$name",
                    "type": "area"
                  },
                  "geometry": {
                    "type": "Polygon",
                    "coordinates": [
                      [
                        [6.618446, 51.439696],
                        [6.618439, 51.439668],
                        [6.618181, 51.439695],
                        [6.618446, 51.439696]
                      ]
                    ]
                  }
                }
              ]
            }
        """.trimIndent()
    }

    private fun extractName(rawJson: String): String {
        return FestivalMapGeoJsonParser()
            .parseLayer(FestivalMapLayerType.Surfaces, rawJson)
            .features
            .single()
            .name
            .orEmpty()
    }
}

private class FakeFestivalMapAssetSource(
    val values: Map<FestivalMapLayerType, String> = FestivalMapLayerType.ordered.associateWith {
        """
            {
              "type": "FeatureCollection",
              "features": [
                {
                  "type": "Feature",
                  "properties": {
                    "name": "Asset ${it.remoteKey}",
                    "type": "area"
                  },
                  "geometry": {
                    "type": "Polygon",
                    "coordinates": [
                      [
                        [6.618446, 51.439696],
                        [6.618439, 51.439668],
                        [6.618181, 51.439695],
                        [6.618446, 51.439696]
                      ]
                    ]
                  }
                }
              ]
            }
        """.trimIndent()
    },
) : FestivalMapAssetSource {

    override fun readLayer(type: FestivalMapLayerType): String {
        return checkNotNull(values[type]) { "Missing asset for ${type.remoteKey}" }
    }
}

private class FakeFestivalMapCacheSource(
    val values: MutableMap<FestivalMapLayerType, String> = mutableMapOf(),
) : FestivalMapCacheSource {

    override fun readLayer(type: FestivalMapLayerType): String? = values[type]

    override fun writeLayer(
        type: FestivalMapLayerType,
        rawJson: String,
    ) {
        values[type] = rawJson
    }
}

private class FakeFestivalMapRemoteSource(
    private val values: MutableMap<FestivalMapLayerType, Result<String>> = mutableMapOf(),
) : FestivalMapRemoteSource {

    override suspend fun fetchLayer(type: FestivalMapLayerType): Result<String> {
        return values[type] ?: Result.failure(IllegalStateException("missing ${type.remoteKey}"))
    }
}

private class FakeFestivalMapRefreshTracker : FestivalMapRefreshTracker {

    override fun shouldRefresh(
        type: FestivalMapLayerType,
        ttlMinutes: Long,
    ): Boolean = true

    override fun markRefreshed(type: FestivalMapLayerType) = Unit
}

private class FakePlaceDao : PlaceDao {
    override fun getPlaces(): Flow<List<PlaceCached>> = flowOf(emptyList())

    override suspend fun savePlaces(places: List<PlaceCached>) = Unit
}
