package com.lambdadigamma.map.presentation

import com.lambdadigamma.core.geo.LocationUpdatesUseCase
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.map.data.model.FestivalMapCoordinate
import com.lambdadigamma.map.data.model.FestivalMapFeature
import com.lambdadigamma.map.data.model.FestivalMapGeometry
import com.lambdadigamma.map.data.model.FestivalMapLayer
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.data.model.FestivalMapPlace
import com.lambdadigamma.map.data.repository.FestivalMapRepository
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.flowOf
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

        val objectUnderTest = buildViewModel(repository)
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
        val objectUnderTest = buildViewModel(repository)
        advanceUntilIdle()

        objectUnderTest.acceptIntent(MapIntent.Refresh)
        advanceUntilIdle()

        assertEquals(listOf(layer(name = "Refreshed")), objectUnderTest.uiState.value.layers)
        assertEquals(3, repository.loadCalls)
        assertEquals(2, repository.refreshCalls)
        assertEquals(false, objectUnderTest.uiState.value.isRefreshing)
    }

    @Test
    fun `should refresh event places when map refresh is requested`() = runTest(dispatcher) {
        val repository = FakeFestivalMapRepository(
            initialLayers = listOf(layer(name = "Initial")),
            initialPlaces = listOf(place()),
        )
        var refreshEventCalls = 0
        val objectUnderTest = buildViewModel(
            repository = repository,
            refreshEventsUseCase = RefreshEventsUseCase {
                refreshEventCalls += 1
                Result.success(Unit)
            },
        )
        advanceUntilIdle()

        objectUnderTest.acceptIntent(MapIntent.Refresh)
        advanceUntilIdle()

        assertEquals(1, refreshEventCalls)
    }

    @Test
    fun `should update selected feature`() = runTest(dispatcher) {
        val selectedLayer = layer(name = "Selectable")
        val repository = FakeFestivalMapRepository(initialLayers = listOf(selectedLayer))
        val objectUnderTest = buildViewModel(repository)
        advanceUntilIdle()

        val feature = selectedLayer.features.single()
        objectUnderTest.acceptIntent(MapIntent.SelectFeature(feature))
        assertEquals(MapSelection.Feature(feature), objectUnderTest.uiState.value.selection)

        objectUnderTest.acceptIntent(MapIntent.ClearSelection)
        assertNull(objectUnderTest.uiState.value.selection)
    }

    @Test
    fun `should expose places and allow place selection`() = runTest(dispatcher) {
        val place = FestivalMapPlace(
            id = 10L,
            name = "Festival Hall",
            point = FestivalMapCoordinate(latitude = 51.44, longitude = 6.62),
            addressLine1 = "Street 1",
            addressLine2 = "47441 Moers",
        )
        val repository = FakeFestivalMapRepository(
            initialLayers = listOf(layer(name = "Initial")),
            initialPlaces = listOf(place),
        )

        val objectUnderTest = buildViewModel(repository)
        advanceUntilIdle()

        assertEquals(listOf(place), objectUnderTest.uiState.value.places)

        objectUnderTest.acceptIntent(MapIntent.SelectPlace(place))

        assertEquals(MapSelection.Place(place), objectUnderTest.uiState.value.selection)
    }

    @Test
    fun `should refresh events once when places are empty`() = runTest(dispatcher) {
        val repository = FakeFestivalMapRepository(initialLayers = listOf(layer(name = "Initial")))
        var refreshCalls = 0

        val objectUnderTest = MapViewModel(
            repository = repository,
            refreshEventsUseCase = RefreshEventsUseCase {
                refreshCalls += 1
                Result.success(Unit)
            },
            locationUpdatesUseCase = fakeLocationUpdatesUseCase(),
        )
        advanceUntilIdle()

        repository.emitPlaces(emptyList())
        advanceUntilIdle()

        assertEquals(1, refreshCalls)
    }

    @Test
    fun `should center on user location`() = runTest(dispatcher) {
        val repository = FakeFestivalMapRepository(initialLayers = listOf(layer(name = "Initial")))
        val expectedLocation = Point(latitude = 51.4401, longitude = 6.6201)
        val objectUnderTest = buildViewModel(
            repository = repository,
            locationUpdatesUseCase = fakeLocationUpdatesUseCase(expectedLocation),
        )
        advanceUntilIdle()

        objectUnderTest.acceptIntent(MapIntent.CenterOnUserLocation)
        advanceUntilIdle()

        assertEquals(expectedLocation, objectUnderTest.uiState.value.userLocation)
        assertEquals(false, objectUnderTest.uiState.value.isLocatingUser)
        assertNull(objectUnderTest.uiState.value.locationError)
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

    private fun place(): FestivalMapPlace {
        return FestivalMapPlace(
            id = 10L,
            name = "Festival Hall",
            point = FestivalMapCoordinate(latitude = 51.44, longitude = 6.62),
            addressLine1 = "Street 1",
            addressLine2 = "47441 Moers",
        )
    }

    private fun buildViewModel(
        repository: FestivalMapRepository,
        refreshEventsUseCase: RefreshEventsUseCase = RefreshEventsUseCase { Result.success(Unit) },
        locationUpdatesUseCase: LocationUpdatesUseCase = fakeLocationUpdatesUseCase(),
    ): MapViewModel {
        return MapViewModel(
            repository = repository,
            refreshEventsUseCase = refreshEventsUseCase,
            locationUpdatesUseCase = locationUpdatesUseCase,
        )
    }

    private fun fakeLocationUpdatesUseCase(
        point: Point? = null,
    ): LocationUpdatesUseCase {
        val updates: Flow<Point> = if (point != null) {
            flowOf(point)
        } else {
            emptyFlow()
        }

        return mockk {
            every { fetchCurrentLocation() } returns updates
        }
    }
}

private class FakeFestivalMapRepository(
    initialLayers: List<FestivalMapLayer>,
    private val refreshedLayers: List<FestivalMapLayer> = initialLayers,
) : FestivalMapRepository {
    private val placesFlow = MutableStateFlow<List<FestivalMapPlace>>(emptyList())

    var loadCalls: Int = 0
        private set

    var refreshCalls: Int = 0
        private set

    private var currentLayers: List<FestivalMapLayer> = initialLayers

    constructor(
        initialLayers: List<FestivalMapLayer>,
        refreshedLayers: List<FestivalMapLayer> = initialLayers,
        initialPlaces: List<FestivalMapPlace>,
    ) : this(
        initialLayers = initialLayers,
        refreshedLayers = refreshedLayers,
    ) {
        placesFlow.value = initialPlaces
    }

    override suspend fun loadLayers(): List<FestivalMapLayer> {
        loadCalls += 1
        return currentLayers
    }

    override fun observePlaces(): Flow<List<FestivalMapPlace>> = placesFlow

    override suspend fun refreshLayers(force: Boolean): Result<Unit> {
        refreshCalls += 1
        if (force) {
            currentLayers = refreshedLayers
        }
        return Result.success(Unit)
    }

    fun emitPlaces(places: List<FestivalMapPlace>) {
        placesFlow.value = places
    }
}
