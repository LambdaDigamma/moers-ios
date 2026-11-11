package com.lambdadigamma.rubbish

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import kotlinx.coroutines.flow.Flow

@Dao
abstract class RubbishDao {

    @Query("SELECT * FROM rubbish_streets ORDER BY name")
    abstract fun observeStreets(): Flow<List<RubbishCollectionStreet>>

    @Query("SELECT COUNT(*) FROM rubbish_streets")
    abstract suspend fun countStreets(): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    abstract suspend fun insertStreets(streets: List<RubbishCollectionStreet>)

    @Query("SELECT * FROM rubbish_collection_items ORDER BY date")
    abstract fun observeCollectionItems(): Flow<List<RubbishCollectionItem>>

    @Query("SELECT * FROM rubbish_collection_items ORDER BY date")
    abstract suspend fun collectionItems(): List<RubbishCollectionItem>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    abstract suspend fun insertCollectionItems(items: List<RubbishCollectionItem>)

    @Query("DELETE FROM rubbish_collection_items")
    abstract suspend fun deleteAllCollectionItems()

    @Transaction
    open suspend fun replaceCollectionItems(items: List<RubbishCollectionItem>) {
        deleteAllCollectionItems()
        insertCollectionItems(items)
    }

}
