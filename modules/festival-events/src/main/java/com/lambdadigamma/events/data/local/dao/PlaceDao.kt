package com.lambdadigamma.events.data.local.dao

import androidx.room.Dao
import androidx.room.Upsert
import com.lambdadigamma.events.data.local.model.PlaceCached

@Dao
interface PlaceDao {

    @Upsert
    suspend fun savePlaces(places: List<PlaceCached>)

}