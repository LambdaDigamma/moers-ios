package com.lambdadigamma.events.data.repository

import android.icu.text.SimpleDateFormat
import com.lambdadigamma.events.data.calculateDateRange
import com.lambdadigamma.events.data.local.dao.EventDao
import com.lambdadigamma.events.data.local.dao.PlaceDao
import com.lambdadigamma.events.data.local.model.FavoriteEventCached
import com.lambdadigamma.events.data.local.model.LikedEventCached
import com.lambdadigamma.events.data.mapper.toDomainModel
import com.lambdadigamma.events.data.mapper.toEntity
import com.lambdadigamma.events.data.mapper.toEntityModel
import com.lambdadigamma.events.data.remote.api.EventService
import com.lambdadigamma.events.data.remote.model.Event
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
import java.util.Date
import java.util.Locale
import javax.inject.Inject

class EventRepositoryImpl @Inject constructor(
    private val eventApi: EventService,
    private val eventDao: EventDao,
    private val pageRepository: PageRepository,
    private val placeDao: PlaceDao,
    private val pageDao: PageDao
) : EventRepository {

    private val dateFormatter = SimpleDateFormat("yyyy-MM-dd", Locale.US)

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

//    override fun getTimetable(): Flow<TimetableData> = flow {
//
//        val dateFormatter = SimpleDateFormat("yyyy-MM-dd", Locale.US)
//
//        val dateRanges = eventDao.loadUniqueDates()
//            .map { dateFormatter.parse(it) ?: Date() }
//            .map { date ->
//                return@map calculateDateRange(
//                    date = date,
//                    offset = 4 * 60 * 60,
//                )
//           }
//
//        println("Timetable: dateRanges = $dateRanges")
//
//        var currentTimetableData = TimetableData(sections = dateRanges.map { range ->
//            TimetableSection(
//                range = range,
//                events = emptyList()
//            )
//        })
//
//        println("Timetable: currentTimetableData = $currentTimetableData")
//
//        dateRanges.forEachIndexed() { index, dateRange ->
//
//            eventDao.getAllEventsWithPlace(dateRange.first.time, dateRange.second.time)
//                .onEach {
//
//                    println("Timetable: Received events for dateRange = $dateRange")
//                    println("Timetable: Received events = $it")
//
//                    currentTimetableData = currentTimetableData.copy(sections = currentTimetableData.sections.toMutableList().apply {
//                        this[index] = TimetableSection(
//                            range = dateRange,
//                            events = it.map { eventWithPlaceCached ->
//                                eventWithPlaceCached.event.toDomainModel().apply {
//                                    place = eventWithPlaceCached.place?.toDomainModel()
//                                    isFavorite = eventWithPlaceCached.favoriteEvent != null
//                                }.toPresentationModel()
//                            }
//                        )
//                    })
//
//                    emit(currentTimetableData)
//
//                }
//                .catch {
//                    throw it
//                }
//
//
//        }
//
//    }

    private val dateRangesFlow = eventDao.getUniqueDates()
        .map { dateStrings ->
            dateStrings.map { dateFormatter.parse(it) ?: Date() }
        }
        .map { dates ->
            return@map dates.map { date ->
                val range = calculateDateRange(
                    date = date,
                    offset = 4 * 60 * 60,
                )
                range
            }
        }
        .catch { error ->
            println("DateRanges error")
            println(error)
        }


    override fun getTimetable(): Flow<TimetableData> {

        return eventDao.getAllEventsWithPlace()
            .map { events ->

                val ranges = events
                    .mapNotNull { it.event.startDate }
                    .map { dateFormatter.format(it) }
                    .distinct()
                    .map {
                        calculateDateRange(
                            date = dateFormatter.parse(it) ?: Date(),
                            offset = 4 * 60 * 60,
                        )
                    }

                val sections = ranges
                    .map { range ->
                        Pair(range, events.filter { item ->
                            val startDate = item.event.startDate
                            if (startDate != null) {
                                return@filter startDate.time in range.first.time..range.second.time
                            } else {
                                return@filter false
                            }
                        })
                    }
                    .map { sections ->
                        val sectionEvents = sections.second
                            .map { item ->

                                item.event.toDomainModel().apply {
                                    place = item.place?.toDomainModel()
                                    isFavorite = item.isLiked // item.favoriteEvent != null
                                }.toPresentationModel()

                            }
                        TimetableSection(events = sectionEvents, range = sections.first)
                    }
                    .toMutableList()

                val undatedEvents = events
                    .filter { it.event.startDate == null }
                    .map { item ->
                        item.event.toDomainModel().apply {
                            place = item.place?.toDomainModel()
                            isFavorite = item.isLiked
                        }.toPresentationModel()
                    }

                if (undatedEvents.isNotEmpty()) {
                    sections += TimetableSection(
                        events = undatedEvents,
                        isUndated = true,
                    )
                }

                TimetableData(sections = sections, currentIndex = 0)
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

        eventDao.deleteAllEvents()
        eventDao.saveEvents(events.map { it.toEntityModel() })
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

                val ranges = events
                    .mapNotNull { it.event!!.event.startDate }
                    .map { dateFormatter.format(it) }
                    .distinct()
                    .map {
                        calculateDateRange(
                            date = dateFormatter.parse(it) ?: Date(),
                            offset = 4 * 60 * 60,
                        )
                    }

                val sections = ranges
                    .map { range ->
                        Pair(range, events.filter { item ->
                            val startDate = item.event!!.event.startDate
                            if (startDate != null) {
                                return@filter startDate.time in range.first.time..range.second.time
                            } else {
                                return@filter false
                            }
                        })
                    }
                    .map { sections ->
                        val sectionEvents = sections.second
                            .map { item ->

                                item.event!!.event.toDomainModel().apply {
                                    place = item.event.place?.toDomainModel()
                                    isFavorite = true
                                }.toPresentationModel()

                            }
                        FavoriteEventsSection(events = sectionEvents, range = sections.first)
                    }
                    .toMutableList()

                val undatedEvents = events
                    .filter { it.event!!.event.startDate == null }
                    .map { item ->
                        item.event!!.event.toDomainModel().apply {
                            place = item.event.place?.toDomainModel()
                            isFavorite = true
                        }.toPresentationModel()
                    }

                if (undatedEvents.isNotEmpty()) {
                    sections += FavoriteEventsSection(
                        events = undatedEvents,
                        isUndated = true,
                    )
                }

                FavoriteEventsData(sections = sections, currentIndex = 0)
            }

    }

}
