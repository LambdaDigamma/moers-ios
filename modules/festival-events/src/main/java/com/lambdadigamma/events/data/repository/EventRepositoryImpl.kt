package com.lambdadigamma.events.data.repository

import com.lambdadigamma.events.data.local.dao.EventDao
import com.lambdadigamma.events.data.local.dao.PlaceDao
import com.lambdadigamma.events.data.local.model.EventWithPlaceAndPageCached
import com.lambdadigamma.events.data.local.model.EventWithPlaceCached
import com.lambdadigamma.events.data.local.model.FavoriteEventInfoCached
import com.lambdadigamma.events.data.local.model.LikedEventCached
import com.lambdadigamma.events.data.mapper.toDomainModel
import com.lambdadigamma.events.data.mapper.toEntity
import com.lambdadigamma.events.data.mapper.toEntityModel
import com.lambdadigamma.events.data.mapper.toSearchIndexCached
import com.lambdadigamma.events.data.remote.api.EventService
import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.data.search.EventSearchTextNormalizer
import com.lambdadigamma.events.data.search.SqlLikeEscaper
import com.lambdadigamma.events.domain.festivalday.FestivalDay
import com.lambdadigamma.events.domain.models.EventDetailData
import com.lambdadigamma.events.domain.repository.EventRepository
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsData
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsSection
import com.lambdadigamma.events.presentation.mapper.toPresentationModel
import com.lambdadigamma.events.presentation.timetable.TimetableData
import com.lambdadigamma.events.presentation.timetable.TimetableSection
import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.mapper.toDomainModel
import com.lambdadigamma.pages.data.mapper.toEntityModel
import com.lambdadigamma.pages.domain.repository.PageRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map
import timber.log.Timber
import javax.inject.Inject

class EventRepositoryImpl @Inject constructor(
    private val eventApi: EventService,
    private val eventDao: EventDao,
    private val pageRepository: PageRepository,
    private val placeDao: PlaceDao,
    private val pageDao: PageDao
) : EventRepository {

    override fun getEvents(): Flow<List<Event>> {
        return eventDao.getAllEventsWithPlace()
            .map { eventsCached ->
                Timber.d("getEvents: eventsCached = $eventsCached")
                eventsCached.map { eventWithPlaceCached ->
                    eventWithPlaceCached.event.toDomainModel().apply {
                        place = eventWithPlaceCached.place?.toDomainModel()
                        page = eventWithPlaceCached.page?.toDomainModel()
                    }
                }
            }
//            .onEach { events ->
//                if (events.isEmpty()) {
//                    refreshEvents()
//                }
//            }
    }

    override fun searchEvents(query: String): Flow<List<Event>> {
        val normalizedQuery = EventSearchTextNormalizer.normalize(query)

        if (normalizedQuery.isEmpty()) {
            return eventDao.getSearchableEvents()
                .map(::mapEventSearchRows)
        }

        val escapedQuery = SqlLikeEscaper.escape(normalizedQuery)

        return eventDao.searchEvents(
            exactPattern = escapedQuery,
            prefixPattern = "$escapedQuery%",
            containsPattern = "%$escapedQuery%",
        ).map(::mapEventSearchRows)
    }

    override fun getTimetable(): Flow<TimetableData> {

        return eventDao.getAllEventsWithPlace()
            .map { events ->
                TimetableData(
                    sections = buildTimetableSections(events),
                    currentIndex = 0,
                )
            }

    }

    override fun getEvent(eventId: Int): Flow<Event?> {

        return eventDao.getEventDetailWithPlace(eventId)
            .map { eventCached ->
                val event = eventCached?.event?.toDomainModel()
                event?.place = eventCached?.place?.toDomainModel()
                event?.isFavorite = eventCached?.favoriteEvent != null
                return@map event
            }

    }

    override fun getPlace(placeId: Long): Flow<com.lambdadigamma.events.data.remote.model.Place?> {
        return placeDao.getPlace(placeId)
            .map { cachedPlace ->
                cachedPlace?.toDomainModel()
            }
    }

    override fun getEventsForPlace(placeId: Long): Flow<List<Event>> {
        return eventDao.getEventsForPlace(placeId.toInt())
            .map { events ->
                events.map { item ->
                    item.event.toDomainModel().apply {
                        place = item.place?.toDomainModel()
                        isFavorite = item.isLiked
                    }
                }
            }
    }

    override fun getEventDetail(eventId: Int): Flow<EventDetailData?> {

        return eventDao.getEventDetailWithPlace(eventId)
            .map { eventCached ->

                if (eventCached == null) {
                    return@map null
                }

                val event = eventCached.event.toDomainModel()
                event.place = eventCached.place?.toDomainModel()

                return@map EventDetailData(event = event, page = null, isFavorite = eventCached.favoriteEvent != null)
            }
            .flatMapLatest { data ->

                val pageId = data?.event?.pageId ?: return@flatMapLatest flowOf(data)

                return@flatMapLatest pageRepository
                    .getPage(pageId)
                    .map { page ->
                        data.copy(page = page)
                    }
                    .catch { error ->
                        Timber.e(error)
                        flowOf(data)
                    }

            }

    }

    override suspend fun refreshEvents() {
        eventApi
            .getAllEvents()
            .data
            .also { events ->
                saveEventsToDao(events)
            }
    }

    override suspend fun loadContent() {

        eventApi
            .getContent()
            .data
            .also { events ->
                saveEventsToDao(events)
            }

    }

    private suspend fun saveEventsToDao(events: List<Event>) {

        eventDao.replaceEventsAndSearchIndex(
            events = events.map { it.toEntityModel() },
            searchIndex = events.map { it.toSearchIndexCached() },
        )
        placeDao.savePlaces(events.mapNotNull { it.place?.toEntity() })

        val pages = events
            .mapNotNull { it.page?.toEntityModel() }

        if (pages.isEmpty()) {
            return
        } else {
            // TODO: This may be not the best option
            // Instead of deleting all pages and blocks, only delete the ones that are in the database.
            pageDao.deletePageBlocksByPageIds(pages.map { it.id })

            val pageBlocks = events
                .flatMap { it.page?.blocks ?: emptyList() }
                .map { it.toEntityModel() }

            pageDao.savePages(pages)
            pageDao.savePageBlocks(pageBlocks)

        }
    }

    override suspend fun toggleFavoriteEvent(eventId: Int) {

        val favoriteEvent = eventDao.getFavoriteEvent(eventId = eventId)

        if (favoriteEvent == null) {
            eventDao.saveFavoriteEvent(LikedEventCached(eventId = eventId))
        } else {
            eventDao.deleteFavoriteEvent(eventId = eventId)
        }

    }

    override fun getFavoriteEvents(): Flow<FavoriteEventsData> {

        return eventDao.getFavoriteEvents()
            .map { events ->
                events
                    .filter { it.event != null }
                    .sortedBy { it.event!!.event.startDate }
            }
            .map { events ->
                FavoriteEventsData(
                    sections = buildFavoriteSections(events),
                    currentIndex = 0,
                )
            }

    }

    private fun buildTimetableSections(
        events: List<EventWithPlaceAndPageCached>,
    ): List<TimetableSection> {
        return FestivalDay
            .sectionsFor(events) { item -> item.event.startDate }
            .map { section ->
                TimetableSection(
                    range = section.range,
                    events = section.items.map { item ->
                        item.event.toDomainModel().apply {
                            place = item.place?.toDomainModel()
                            isFavorite = item.isLiked
                        }.toPresentationModel()
                    },
                    isUndated = section.isUndated,
                )
            }
    }

    private fun buildFavoriteSections(
        events: List<FavoriteEventInfoCached>,
    ): List<FavoriteEventsSection> {
        return FestivalDay
            .sectionsFor(events) { item -> item.event?.event?.startDate }
            .map { section ->
                FavoriteEventsSection(
                    range = section.range,
                    events = section.items.map { item ->
                        val favoriteEvent = requireNotNull(item.event)
                        favoriteEvent.event.toDomainModel().apply {
                            place = favoriteEvent.place?.toDomainModel()
                            isFavorite = true
                        }.toPresentationModel()
                    },
                    isUndated = section.isUndated,
                )
            }
    }

    private fun mapEventSearchRows(
        events: List<EventWithPlaceCached>,
    ): List<Event> {
        return events.map { item ->
            item.event.toDomainModel().apply {
                place = item.place?.toDomainModel()
                isFavorite = item.isLiked == true
            }
        }
    }

}
