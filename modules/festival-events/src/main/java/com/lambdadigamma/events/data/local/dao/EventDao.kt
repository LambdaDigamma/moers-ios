package com.lambdadigamma.events.data.local.dao

import androidx.lifecycle.LiveData
import androidx.lifecycle.asFlow
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Upsert
import com.lambdadigamma.events.data.local.model.EventCached
import com.lambdadigamma.events.data.local.model.EventWithPlaceAndPageCached
import com.lambdadigamma.events.data.local.model.EventWithPlaceCached
import com.lambdadigamma.events.data.local.model.FavoriteEventCached
import com.lambdadigamma.events.data.local.model.FavoriteEventInfoCached
import com.lambdadigamma.events.data.local.model.LikedEventCached
import com.lambdadigamma.pages.data.local.model.PageWithBlocksCached
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filterNotNull

@Dao
interface EventDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertEvents(events: List<EventCached>): List<Long>

    @Upsert
    suspend fun saveEvents(events: List<EventCached>)

    @Query("SELECT * FROM events")
    fun getEvents(): LiveData<List<EventCached>>

    @Query("SELECT * FROM events ORDER BY startDate ASC")
    fun getAllEvents(): Flow<List<EventCached>>

    @Transaction
    @Query("SELECT events.*, CASE WHEN liked_events.eventId IS NOT NULL THEN 1 ELSE 0 END AS isLiked FROM events LEFT JOIN liked_events ON events.id = liked_events.eventId ORDER BY startDate ASC")
    fun getAllEventsWithPlace(): Flow<List<EventWithPlaceAndPageCached>>

    @Query("SELECT * FROM events WHERE id = :id")
    fun getEvent(id: Int): LiveData<EventCached>

    @Query("SELECT * FROM events WHERE id = :id")
    fun getEventDetail(id: Int): Flow<EventCached?>

    @Transaction
    @Query("SELECT events.*, CASE WHEN liked_events.eventId IS NOT NULL THEN 1 ELSE 0 END AS isLiked FROM events LEFT JOIN liked_events ON events.id = liked_events.eventId WHERE events.id = :id")
    fun getEventDetailWithPlace(id: Int): Flow<EventWithPlaceCached?>

    @Transaction
    @Query("SELECT events.*, CASE WHEN liked_events.eventId IS NOT NULL THEN 1 ELSE 0 END AS isLiked FROM events LEFT JOIN liked_events ON events.id = liked_events.eventId WHERE startDate >= :startDate AND endDate <= :endDate ORDER BY startDate ASC")
    fun getAllEventsWithPlace(
        startDate: Long,
        endDate: Long
    ): Flow<List<EventWithPlaceCached>>

    @Transaction
    @Query("SELECT events.*, CASE WHEN liked_events.eventId IS NOT NULL THEN 1 ELSE 0 END AS isLiked FROM events LEFT JOIN liked_events ON events.id = liked_events.eventId WHERE placeId = :placeId ORDER BY startDate ASC")
    fun getEventsForPlace(placeId: Int): Flow<List<EventWithPlaceCached>>

    @Query("DELETE FROM events")
    suspend fun deleteAllEvents()

    @Query("SELECT DISTINCT strftime('%Y-%m-%d', datetime(startDate / 1000, 'unixepoch')) AS date FROM events")
    fun getUniqueDates(): Flow<List<String>>

    @Query("SELECT DISTINCT strftime('%Y-%m-%d', datetime(startDate / 1000, 'unixepoch')) AS date FROM events")
    suspend fun loadUniqueDates(): List<String>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun saveFavoriteEvent(favoriteEvent: LikedEventCached)

    @Query("DELETE FROM liked_events WHERE eventId = :eventId")
    suspend fun deleteFavoriteEvent(eventId: Int)

    @Transaction
    @Query("SELECT * FROM liked_events WHERE eventId = :eventId")
    suspend fun getFavoriteEvent(eventId: Int): LikedEventCached?

    @Transaction
    @Query("SELECT * FROM liked_events")
    fun getFavoriteEvents(): Flow<List<FavoriteEventInfoCached>>


//    @Transaction
//    @Query("SELECT * FROM events WHERE id = :pageId")
//    fun getEventDetail(pageId: Int): Flow<PageWithBlocksCached?>
}
