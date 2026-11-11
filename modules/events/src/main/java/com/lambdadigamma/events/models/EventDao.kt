package com.lambdadigamma.events.models

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

@Dao
abstract class EventDao {

    @Query("SELECT * FROM events ORDER BY startDate")
    abstract fun observeEvents(): Flow<List<Event>>

    @Query("SELECT * FROM events WHERE id = :id")
    abstract fun observeEvent(id: Int): Flow<Event?>

    @Upsert
    abstract suspend fun upsert(events: List<Event>)

    @Query("DELETE FROM events WHERE id NOT IN (:ids)")
    abstract suspend fun deleteAllExcept(ids: List<Int>)

    /** Replaces the cache with [events], removing events that are no longer published. */
    @Transaction
    open suspend fun replaceAll(events: List<Event>) {
        upsert(events)
        deleteAllExcept(events.map { it.id })
    }

}
