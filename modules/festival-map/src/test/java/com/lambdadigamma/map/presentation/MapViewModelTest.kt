package com.lambdadigamma.map.presentation

import com.lambdadigamma.map.data.model.FestivalMapCoordinate
import com.lambdadigamma.map.data.model.FestivalMapFeature
import com.lambdadigamma.map.data.model.FestivalMapGeometry
import com.lambdadigamma.map.data.model.FestivalMapLayer
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.data.repository.FestivalMapRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
class MapViewModelTest {

    private val dispatcher = StandardTestDispatcher()

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `should load layers on init`() = runTest(dispatcher) {
        val initialLayers = listOf(layer(name = "Initial"))
        val repository = FakeFestivalMapRepository(initialLayers = initialLayers)

        val objectUnderTest = MapViewModel(repository)
        advanceUntilIdle()

        assertEquals(initialLayers, objectUnderTest.uiState.value.layers)
        assertEquals(false, objectUnderTest.uiState.value.isLoading)
        assertEquals(false, objectUnderTest.uiState.value.isRefreshing)
        assertNull(objectUnderTest.uiState.value.refreshError)
    }

    @Test
    fun `should refresh layers when requested`() = runTest(dispatcher) {
        val repository = FakeFestivalMapRepository(
            initialLayers = listOf(layer(name = "Initial")),
            refreshedLayers = listOf(layer(name = "Refreshed")),
        )
        val objectUnderTest = MapViewModel(repository)
        advanceUntilIdle()

        objectUnderTest.acceptIntent(MapIntent.Refresh)
        advanceUntilIdle()

        assertEquals(listOf(layer(name = "Refreshed")), objectUnderTest.uiState.value.layers)
        assertEquals(3, repository.loadCalls)
        assertEquals(2, repository.refreshCalls)
        assertEquals(false, objectUnderTest.uiState.value.isRefreshing)
    }

    @Test
    fun `should update selected feature`() = runTest(dispatcher) {
        val selectedLayer = layer(name = "Selectable")
        val repository = FakeFestivalMapRepository(initialLayers = listOf(selectedLayer))
        val objectUnderTest = MapViewModel(repository)
        advanceUntilIdle()

        val feature = selectedLayer.features.single()
        objectUnderTest.acceptIntent(MapIntent.SelectFeature(feature))
        assertEquals(feature, objectUnderTest.uiState.value.selectedFeature)

        objectUnderTest.acceptIntent(MapIntent.ClearSelection)
        assertNull(objectUnderTest.uiState.value.selectedFeature)
    }

    private fun layer(name: String): FestivalMapLayer {
        return FestivalMapLayer(
            type = FestivalMapLayerType.Surfaces,
            features = listOf(
                FestivalMapFeature(
                    id = name,
                    layerType = FestivalMapLayerType.Surfaces,
                    name = name,
                    featureType = "area",
                    description = null,
                    boothNumber = null,
                    isFood = null,
                    geometry = FestivalMapGeometry.Polygon(
                        rings = listOf(
                            listOf(
                                FestivalMapCoordinate(51.439696, 6.618446),
                                FestivalMapCoordinate(51.439668, 6.618439),
                                FestivalMapCoordinate(51.439695, 6.618181),
                                FestivalMapCoordinate(51.439696, 6.618446),
                            ),
                        ),
                    ),
                ),
            ),
        )
    }
}

private class FakeFestivalMapRepository(
    initialLayers: List<FestivalMapLayer>,
    private val refreshedLayers: List<FestivalMapLayer> = initialLayers,
) : FestivalMapRepository {

    var loadCalls: Int = 0
        private set

    var refreshCalls: Int = 0
        private set

    private var currentLayers: List<FestivalMapLayer> = initialLayers

    override suspend fun loadLayers(): List<FestivalMapLayer> {
        loadCalls += 1
        return currentLayers
    }

    override suspend fun refreshLayers(force: Boolean): Result<Unit> {
        refreshCalls += 1
        if (force) {
            currentLayers = refreshedLayers
        }
        return Result.success(Unit)
    }
}
