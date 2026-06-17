package com.lambdadigamma.events.presentation.timetable

import androidx.lifecycle.SavedStateHandle
import app.cash.turbine.test
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.refresh.FakeRefreshMetadataStore
import com.lambdadigamma.core.refresh.RefreshMetadataKey
import com.lambdadigamma.core.refresh.RefreshMetadataStore
import com.lambdadigamma.events.data.local.preferences.TimetableFilterRepository
import com.lambdadigamma.events.domain.usecase.GetTimetableUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import com.lambdadigamma.events.presentation.filter.EventFilter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.io.IOException
import java.util.Date
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class TimetableViewModelTest {

    private val dispatcher = UnconfinedTestDispatcher()

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `should keep cached sections after refresh failure`() = runTest(dispatcher) {
        val timetableResults = MutableSharedFlow<Result<TimetableData>>(replay = 1)
        val objectUnderTest = buildViewModel(
            timetableResults = timetableResults,
            refreshEventsUseCase = failingRefreshUseCase(),
        )

        timetableResults.emit(Result.success(timetableData()))
        advanceUntilIdle()

        objectUnderTest.acceptIntent(TimetableIntent.RefreshEvents)
        advanceUntilIdle()

        assertEquals(listOf(1), objectUnderTest.uiState.value.data.sections.single().events.map(EventDisplayable::id))
        assertFalse(objectUnderTest.uiState.value.isRefreshing)
        assertNull(objectUnderTest.uiState.value.isError)
    }

    @Test
    fun `should show blocking error when refresh fails without cached events`() = runTest(dispatcher) {
        val timetableResults = MutableSharedFlow<Result<TimetableData>>(replay = 1)
        val objectUnderTest = buildViewModel(
            timetableResults = timetableResults,
            refreshEventsUseCase = failingRefreshUseCase(),
        )

        timetableResults.emit(Result.success(TimetableData(currentIndex = 0)))
        advanceUntilIdle()

        objectUnderTest.acceptIntent(TimetableIntent.RefreshEvents)
        advanceUntilIdle()

        assertTrue(objectUnderTest.uiState.value.data.sections.isEmpty())
        assertNotNull(objectUnderTest.uiState.value.isError)
        assertFalse(objectUnderTest.uiState.value.isRefreshing)
    }

    @Test
    fun `should keep filtered empty state after refresh failure when cached events exist`() = runTest(dispatcher) {
        val timetableResults = MutableSharedFlow<Result<TimetableData>>(replay = 1)
        val objectUnderTest = buildViewModel(
            timetableResults = timetableResults,
            refreshEventsUseCase = failingRefreshUseCase(),
            filterRepository = FakeTimetableFilterRepository(
                EventFilter(showOnlyFavorites = true),
            ),
        )

        timetableResults.emit(Result.success(timetableData(isFavorite = false)))
        advanceUntilIdle()

        assertTrue(objectUnderTest.uiState.value.data.sections.isEmpty())
        assertTrue(objectUnderTest.uiState.value.data.hasAnyEvents)

        objectUnderTest.acceptIntent(TimetableIntent.RefreshEvents)
        advanceUntilIdle()

        assertTrue(objectUnderTest.uiState.value.data.sections.isEmpty())
        assertTrue(objectUnderTest.uiState.value.data.hasAnyEvents)
        assertNull(objectUnderTest.uiState.value.isError)
    }

    @Test
    fun `should emit retryable refresh error event when cached events exist`() = runTest(dispatcher) {
        val lastSuccessfulRefresh = Date(123_456L)
        val timetableResults = MutableSharedFlow<Result<TimetableData>>(replay = 1)
        val objectUnderTest = buildViewModel(
            timetableResults = timetableResults,
            refreshEventsUseCase = failingRefreshUseCase(),
            refreshMetadataStore = FakeRefreshMetadataStore(
                mutableMapOf(RefreshMetadataKey.TIMETABLE to lastSuccessfulRefresh),
            ),
        )

        timetableResults.emit(Result.success(timetableData()))
        advanceUntilIdle()

        objectUnderTest.event.test {
            objectUnderTest.acceptIntent(TimetableIntent.RefreshEvents)
            advanceUntilIdle()

            val event = assertIs<TimetableEvents.ShowRefreshError>(awaitItem())
            assertEquals(lastSuccessfulRefresh, event.lastSuccessfulRefresh)
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `should emit retryable refresh error event without timestamp when timestamp read fails`() = runTest(dispatcher) {
        val timetableResults = MutableSharedFlow<Result<TimetableData>>(replay = 1)
        val objectUnderTest = buildViewModel(
            timetableResults = timetableResults,
            refreshEventsUseCase = failingRefreshUseCase(),
            refreshMetadataStore = FakeRefreshMetadataStore(
                readFailure = IOException("DataStore unavailable"),
            ),
        )

        timetableResults.emit(Result.success(timetableData()))
        advanceUntilIdle()

        objectUnderTest.event.test {
            objectUnderTest.acceptIntent(TimetableIntent.RefreshEvents)
            advanceUntilIdle()

            val event = assertIs<TimetableEvents.ShowRefreshError>(awaitItem())
            assertNull(event.lastSuccessfulRefresh)
            cancelAndIgnoreRemainingEvents()
        }
    }

    private fun buildViewModel(
        timetableResults: Flow<Result<TimetableData>>,
        refreshEventsUseCase: RefreshEventsUseCase,
        filterRepository: TimetableFilterRepository = FakeTimetableFilterRepository(),
        refreshMetadataStore: RefreshMetadataStore = FakeRefreshMetadataStore(),
    ): TimetableViewModel {
        return TimetableViewModel(
            getTimetableUseCase = GetTimetableUseCase { timetableResults },
            refreshEventsUseCase = refreshEventsUseCase,
            filterRepository = filterRepository,
            refreshMetadataStore = refreshMetadataStore,
            savedStateHandle = SavedStateHandle(),
            eventsInitialState = TimetableUiState(),
        )
    }

    private fun failingRefreshUseCase(): RefreshEventsUseCase {
        return RefreshEventsUseCase {
            Result.failure(IOException("No network"))
        }
    }

    private fun timetableData(
        isFavorite: Boolean = true,
    ): TimetableData {
        return TimetableData(
            currentIndex = 0,
            sections = listOf(
                TimetableSection(
                    events = listOf(eventDisplayable(isFavorite = isFavorite)),
                ),
            ),
        )
    }

    private fun eventDisplayable(
        isFavorite: Boolean,
    ): EventDisplayable {
        return EventDisplayable(
            id = 1,
            name = "Event 1",
            startDate = Date(1_000L),
            endDate = Date(2_000L),
            place = PlaceDisplayable(
                id = 1L,
                name = "Festival Hall",
                point = Point(latitude = 51.44, longitude = 6.62),
                addressLine1 = "Street 1",
                addressLine2 = "47441 Moers",
            ),
            isFavorite = isFavorite,
            isOpenEnd = false,
        )
    }
}
