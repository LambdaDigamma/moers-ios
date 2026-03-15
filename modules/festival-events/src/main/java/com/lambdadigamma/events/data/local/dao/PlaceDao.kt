package com.lambdadigamma.events.data.local.dao

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert
import com.lambdadigamma.events.data.local.model.PlaceCached
import kotlinx.coroutines.flow.Flow

@Dao
interface PlaceDao {

    @Query(
        """
        SELECT DISTINCT places.* FROM places
        INNER JOIN events ON events.placeId = places.id
        WHERE events.collection = :collection
        ORDER BY places.name ASC
        """
    )
    fun getFestivalPlaces(collection: String): Flow<List<PlaceCached>>

    @Query("SELECT * FROM places WHERE id = :id LIMIT 1")
    fun getPlace(id: Long): Flow<PlaceCached?>

    @Upsert
    suspend fun savePlaces(places: List<PlaceCached>)

}
