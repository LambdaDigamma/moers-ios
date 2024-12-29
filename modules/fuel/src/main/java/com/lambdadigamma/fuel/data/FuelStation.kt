package com.lambdadigamma.fuel.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.lambdadigamma.core.geo.Point

@Entity(tableName = "fuel_stations")
data class FuelStation(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "name") val name: String,
    @ColumnInfo(name = "latitude") val lat: Double,
    @ColumnInfo(name = "longitude") val lng: Double,
    @ColumnInfo(name = "brand") val brand: String,
    @ColumnInfo(name = "street") val street: String,
    @ColumnInfo(name = "place") val place: String,
    @ColumnInfo(name = "house_number") val houseNumber: String?,
    @ColumnInfo(name = "post_code") val postCode: String?,
    @ColumnInfo(name = "current_distance") val dist: Double?,
    @ColumnInfo(name = "diesel_price") val diesel: Double?,
    @ColumnInfo(name = "e5_price") val e5: Double?,
    @ColumnInfo(name = "e10_price") val e10: Double?,
    @ColumnInfo(name = "requested_price") val price: Double?,
    @ColumnInfo(name = "is_open") val isOpen: Boolean,
    @ColumnInfo(name = "whole_day") val wholeDay: Boolean?,
    @ColumnInfo(name = "opening_times") val openingTimes: List<FuelStationTimeEntry>?,
    @ColumnInfo(name = "override_opening_times") val overrides: List<String>?,
    @ColumnInfo(name = "state") val state: String?
) {

    val coordinate: Point
        get() {
            return Point(latitude = lat, longitude = lng)
        }

}