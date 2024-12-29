package com.lambdadigamma.fuel.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface FuelDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFuelStations(fuelStations: List<FuelStation>)

    @Query("SELECT * FROM fuel_stations")
    suspend fun getFuelStations(): List<FuelStation>

    @Query("SELECT * FROM fuel_stations WHERE id = :id")
    suspend fun getFuelStation(id: String): FuelStation

    @Query("DELETE FROM fuel_stations")
    suspend fun deleteAllFuelStations()

}