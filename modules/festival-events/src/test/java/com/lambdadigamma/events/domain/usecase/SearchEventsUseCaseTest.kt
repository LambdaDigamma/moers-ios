package com.lambdadigamma.events.domain.usecase

import app.cash.turbine.test
import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.domain.repository.EventRepository
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import java.io.IOException
import kotlin.test.assertEquals

@OptIn(ExperimentalCoroutinesApi::class)
class SearchEventsUseCaseTest {

    private val repository = mockk<EventRepository>()

    @Test
    fun `should emit success when repository returns search results`() = runTest {
        val events = listOf(Event(id = 1, name = "Piano Night"))
        every { repository.searchEvents("piano") } returns flowOf(events)

        searchEvents("piano", repository).test {
            assertEquals(events, awaitItem().getOrNull())
            awaitComplete()
        }
    }

    @Test
    fun `should emit failure and retry after io exception`() = runTest {
        val ioException = IOException("Temporary database issue")
        val events = listOf(Event(id = 1, name = "Piano Night"))
        var attempt = 0

        every { repository.searchEvents("piano") } returns flow {
            if (attempt++ == 0) {
                throw ioException
            }

            emit(events)
        }

        searchEvents("piano", repository).test {
            assertEquals(ioException, awaitItem().exceptionOrNull())

            advanceTimeBy(15_000)

            assertEquals(events, awaitItem().getOrNull())
            awaitComplete()
        }
    }
}
