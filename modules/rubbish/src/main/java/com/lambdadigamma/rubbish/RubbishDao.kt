package com.lambdadigamma.rubbish

import androidx.lifecycle.LiveData
import androidx.room.*

@Dao
interface RubbishDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertRubbishStreets(streets: List<RubbishCollectionStreet>): List<Long>

    @Query("SELECT * FROM rubbish_streets")
    fun getRubbishStreets(): LiveData<List<RubbishCollectionStreet>>

    @Query("SELECT * FROM rubbish_streets WHERE name LIKE '%' || :streetName || '%'")
    fun getRubbishStreet(streetName: String): LiveData<List<RubbishCollectionStreet>>

    @Query("SELECT * FROM rubbish_collection_items")
    fun loadAllRubbishCollectionItems(): LiveData<List<RubbishCollectionItem>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertRubbishCollectionItems(items: List<RubbishCollectionItem>)

    @Delete
    fun deleteRubbishCollectionItems(vararg items: RubbishCollectionItem)

    @Query("DELETE FROM rubbish_collection_items")
    fun deleteAllRubbishCollectionItems()

}