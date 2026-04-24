package com.lambdadigamma.events.domain.usecase

import app.cash.turbine.test
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.events.domain.repository.EventRepository
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsData
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsSection
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import java.io.IOException
import java.util.Date
import kotlin.test.assertEquals

@OptIn(ExperimentalCoroutinesApi::class)
class GetFavoriteEventsUseCaseTest {

    private val repository = mockk<EventRepository>()

    @Test
    fun `should emit success when repository returns favorite events`() = runTest {
        val favoriteEvents = favoriteEventsData()
        every { repository.getFavoriteEvents() } returns flowOf(favoriteEvents)

        getFavoriteEvents(repository).test {
            assertEquals(favoriteEvents, awaitItem().getOrNull())
            awaitComplete()
        }
    }

    @Test
    fun `should emit failure and retry after io exception`() = runTest {
        val ioException = IOException("Temporary network issue")
        val favoriteEvents = favoriteEventsData()
        var attempt = 0

        every { repository.getFavoriteEvents() } returns flow {
            if (attempt++ == 0) {
                throw ioException
            }

            emit(favoriteEvents)
        }

        getFavoriteEvents(repository).test {
            assertEquals(ioException, awaitItem().exceptionOrNull())

            advanceTimeBy(15_000)

            assertEquals(favoriteEvents, awaitItem().getOrNull())
            awaitComplete()
        }
    }

    @Test
    fun `should emit failure and complete on non io exception`() = runTest {
        val exception = IllegalStateException("Unexpected failure")
        every { repository.getFavoriteEvents() } returns flow {
            throw exception
        }

        getFavoriteEvents(repository).test {
            assertEquals(exception, awaitItem().exceptionOrNull())
            awaitComplete()
        }
    }

    private fun favoriteEventsData(): FavoriteEventsData {
        return FavoriteEventsData(
            sections = listOf(
                FavoriteEventsSection(
                    events = listOf(
                        EventDisplayable(
                            id = 1,
                            name = "Favorite Event",
                            startDate = Date(1_000),
                            endDate = Date(2_000),
                            place = PlaceDisplayable(
                                id = 7L,
                                name = "Festival Hall",
                                point = Point(latitude = 51.44, longitude = 6.62),
                                addressLine1 = "Street 1",
                                addressLine2 = "47441 Moers",
                            ),
                            isFavorite = true,
                            isOpenEnd = false,
                        ),
                    ),
                ),
            ),
        )
    }
}
