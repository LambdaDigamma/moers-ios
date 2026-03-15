package com.lambdadigamma.events.data.local.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName
import java.util.Date

@Entity(tableName = "places")
data class PlaceCached(
    @PrimaryKey val id: Long,
    val lat: Double,
    val lng: Double,
    val name: String,
    val streetName: String?,
    val streetNumber: String?,
    val streetAddition: String?,
    val postalCode: String?,
    val postalTown: String?,
    val countryCode: String?,
    val tags: String,
    val url: String?,
    val phone: String?,
    val pageID: Long?,
    val validatedAt: Date?,
    val createdAt: Date?,
    val updatedAt: Date?,
    val deletedAt: Date?,
)