package com.lambdadigamma.events.data.local.dao

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert
import com.lambdadigamma.events.data.local.model.PlaceCached
import kotlinx.coroutines.flow.Flow

@Dao
interface PlaceDao {

    @Query("SELECT * FROM places ORDER BY name ASC")
    fun getPlaces(): Flow<List<PlaceCached>>

    @Upsert
    suspend fun savePlaces(places: List<PlaceCached>)

}
