package com.lambdadigamma.events.data.repository

import app.cash.turbine.test
import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.core.refresh.FakeRefreshMetadataStore
import com.lambdadigamma.core.refresh.RefreshMetadataKey
import com.lambdadigamma.core.refresh.RefreshMetadataStore
import com.lambdadigamma.events.data.local.dao.EventDao
import com.lambdadigamma.events.data.local.dao.PlaceDao
import com.lambdadigamma.events.data.local.model.EventCached
import com.lambdadigamma.events.data.local.model.EventSearchIndexCached
import com.lambdadigamma.events.data.local.model.EventWithPlaceCached
import com.lambdadigamma.events.data.local.model.LikedEventCached
import com.lambdadigamma.events.data.remote.api.EventService
import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.remote.model.Page
import com.lambdadigamma.pages.domain.repository.PageRepository
import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import java.io.IOException
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class EventRepositoryImplTest {

    private val eventApi = mockk<EventService>(relaxed = true)
    private val eventDao = mockk<EventDao>()
    private val pageRepository = mockk<PageRepository>()
    private val placeDao = mockk<PlaceDao>(relaxed = true)
    private val pageDao = mockk<PageDao>(relaxed = true)

    @Test
    fun `getEventDetail emits cached metadata when page repository fails`() = runTest {
        val eventId = 42
        val pageId = 7
        every { eventDao.getEventDetailWithPlace(eventId) } returns flowOf(
            EventWithPlaceCached(
                event = EventCached(
                    id = eventId,
                    name = "Cached event",
                    pageId = pageId,
                ),
                place = null,
                favoriteEvent = LikedEventCached(eventId = eventId),
                isLiked = true,
            ),
        )
        every { pageRepository.getPage(pageId) } returns flow<Page?> {
            throw IOException("Page refresh failed")
        }

        val repository = buildRepository()

        repository.getEventDetail(eventId).test {
            val detail = awaitItem()

            assertEquals(eventId, detail?.event?.id)
            assertEquals("Cached event", detail?.event?.name)
            assertEquals(true, detail?.isFavorite)
            assertNull(detail?.page)
            awaitComplete()
        }
    }

    @Test
    fun `refreshEvents marks timetable refresh after successful cache save`() = runTest {
        val refreshMetadataStore = FakeRefreshMetadataStore()
        coEvery { eventApi.getAllEvents() } returns DataResponse(
            listOf(Event(id = 1, name = "Remote event")),
        )
        coEvery {
            eventDao.replaceEventsAndSearchIndex(
                events = any<List<EventCached>>(),
                searchIndex = any<List<EventSearchIndexCached>>(),
            )
        } returns Unit

        buildRepository(refreshMetadataStore).refreshEvents()

        assertEquals(listOf(RefreshMetadataKey.TIMETABLE), refreshMetadataStore.markedKeys)
    }

    @Test
    fun `refreshEvents does not mark timetable refresh when cache save fails`() = runTest {
        val refreshMetadataStore = FakeRefreshMetadataStore()
        coEvery { eventApi.getAllEvents() } returns DataResponse(
            listOf(Event(id = 1, name = "Remote event")),
        )
        coEvery {
            eventDao.replaceEventsAndSearchIndex(
                events = any<List<EventCached>>(),
                searchIndex = any<List<EventSearchIndexCached>>(),
            )
        } throws IOException("Database unavailable")

        runCatching {
            buildRepository(refreshMetadataStore).refreshEvents()
        }

        assertEquals(emptyList(), refreshMetadataStore.markedKeys)
    }

    @Test
    fun `refreshEvents succeeds when timestamp write fails`() = runTest {
        val refreshMetadataStore = FakeRefreshMetadataStore(
            writeFailure = IOException("DataStore unavailable"),
        )
        coEvery { eventApi.getAllEvents() } returns DataResponse(
            listOf(Event(id = 1, name = "Remote event")),
        )
        coEvery {
            eventDao.replaceEventsAndSearchIndex(
                events = any<List<EventCached>>(),
                searchIndex = any<List<EventSearchIndexCached>>(),
            )
        } returns Unit

        val result = runCatching {
            buildRepository(refreshMetadataStore).refreshEvents()
        }

        assertTrue(result.isSuccess)
    }

    private fun buildRepository(
        refreshMetadataStore: RefreshMetadataStore = FakeRefreshMetadataStore(),
    ): EventRepositoryImpl {
        return EventRepositoryImpl(
            eventApi = eventApi,
            eventDao = eventDao,
            pageRepository = pageRepository,
            placeDao = placeDao,
            pageDao = pageDao,
            refreshMetadataStore = refreshMetadataStore,
        )
    }
}
