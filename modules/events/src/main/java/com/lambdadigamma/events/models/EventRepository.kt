package com.lambdadigamma.events.models

import com.lambdadigamma.core.extensions.resultOf
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class EventRepository @Inject constructor(
    private val eventDao: EventDao,
    private val eventService: EventService,
) {

    val events: Flow<List<Event>> = eventDao.observeEvents()

    fun event(id: Int): Flow<Event?> = eventDao.observeEvent(id)

    /** Loads all published events. The API serves at most [PAGE_SIZE] events per page. */
    suspend fun refresh(): Result<Unit> = resultOf {
        val firstPage = eventService.getEvents(PAGE_SIZE, 1)
        val lastPage = (firstPage.meta?.lastPage ?: 1).coerceIn(1, MAX_PAGES)
        val otherPages = coroutineScope {
            (2..lastPage).map { page -> async { eventService.getEvents(PAGE_SIZE, page) } }.awaitAll()
        }
        val events = (listOf(firstPage) + otherPages)
            .flatMap { it.data.orEmpty() }
            .mapNotNull { it.toEvent() }
            .distinctBy { it.id }
        eventDao.replaceAll(events)
    }

    suspend fun refreshEvent(id: Int): Result<Unit> = resultOf {
        val event = eventService.getEvent(id).toEvent()
        if (event != null) eventDao.upsert(listOf(event))
    }

    companion object {
        const val PAGE_SIZE = 30
        private const val MAX_PAGES = 50
    }
}
