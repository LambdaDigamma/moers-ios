package com.lambdadigamma.events.models

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface EventDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertEvents(events: List<Event>): List<Long>

    @Query("SELECT * FROM events")
    fun getEvents(): LiveData<List<Event>>

    @Query("SELECT * FROM events WHERE id = :id")
    fun getEvent(id: Int): LiveData<Event>

}