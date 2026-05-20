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
import com.lambdadigamma.events.data.local.model.EventSearchIndexCached
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

    @Upsert
    suspend fun saveEventSearchIndex(searchIndex: List<EventSearchIndexCached>)

    @Transaction
    suspend fun replaceEventsAndSearchIndex(
        events: List<EventCached>,
        searchIndex: List<EventSearchIndexCached>,
    ) {
        deleteAllEvents()
        saveEvents(events)
        saveEventSearchIndex(searchIndex)
    }

    @Transaction
    @Query(
        """
        SELECT events.*, CASE WHEN liked_events.eventId IS NOT NULL THEN 1 ELSE 0 END AS isLiked
        FROM events
        LEFT JOIN liked_events ON events.id = liked_events.eventId
        ORDER BY
            events.startDate IS NULL ASC,
            events.startDate ASC,
            events.name COLLATE NOCASE ASC
        """
    )
    fun getSearchableEvents(): Flow<List<EventWithPlaceCached>>

    @Transaction
    @Query(
        """
        SELECT events.*, CASE WHEN liked_events.eventId IS NOT NULL THEN 1 ELSE 0 END AS isLiked
        FROM events
        INNER JOIN event_search_index ON event_search_index.eventId = events.id
        LEFT JOIN liked_events ON events.id = liked_events.eventId
        WHERE event_search_index.normalizedName LIKE :containsPattern ESCAPE '\'
            OR event_search_index.normalizedArtists LIKE :containsPattern ESCAPE '\'
            OR event_search_index.normalizedPlaceName LIKE :containsPattern ESCAPE '\'
        ORDER BY
            CASE
                WHEN event_search_index.normalizedName LIKE :exactPattern ESCAPE '\' THEN 0
                WHEN event_search_index.normalizedName LIKE :prefixPattern ESCAPE '\' THEN 1
                WHEN event_search_index.normalizedName LIKE :containsPattern ESCAPE '\' THEN 2
                WHEN event_search_index.normalizedArtists LIKE :exactPattern ESCAPE '\' THEN 3
                WHEN event_search_index.normalizedArtists LIKE :prefixPattern ESCAPE '\' THEN 4
                WHEN event_search_index.normalizedArtists LIKE :containsPattern ESCAPE '\' THEN 5
                WHEN event_search_index.normalizedPlaceName LIKE :exactPattern ESCAPE '\' THEN 6
                WHEN event_search_index.normalizedPlaceName LIKE :prefixPattern ESCAPE '\' THEN 7
                WHEN event_search_index.normalizedPlaceName LIKE :containsPattern ESCAPE '\' THEN 8
                ELSE 9
            END ASC,
            events.startDate IS NULL ASC,
            events.startDate ASC,
            events.name COLLATE NOCASE ASC
        """
    )
    fun searchEvents(
        exactPattern: String,
        prefixPattern: String,
        containsPattern: String,
    ): Flow<List<EventWithPlaceCached>>

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
