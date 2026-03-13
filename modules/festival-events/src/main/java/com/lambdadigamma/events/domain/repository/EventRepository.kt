package com.lambdadigamma.events.domain.repository

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.domain.models.EventDetailData
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsData
import com.lambdadigamma.events.presentation.timetable.TimetableData
import kotlinx.coroutines.flow.Flow

interface EventRepository {

    fun getEvents(): Flow<List<Event>>

    fun getTimetable(): Flow<TimetableData>

    suspend fun refreshEvents()

    suspend fun loadContent()

    suspend fun toggleFavoriteEvent(eventId: Int)

    fun getEvent(eventId: Int): Flow<Event?>

    fun getEventDetail(eventId: Int): Flow<EventDetailData?>

    fun getFavoriteEvents(): Flow<FavoriteEventsData>

}