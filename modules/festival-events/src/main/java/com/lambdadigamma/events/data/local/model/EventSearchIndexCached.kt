package com.lambdadigamma.events.data.local.model

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "event_search_index",
    foreignKeys = [
        ForeignKey(
            entity = EventCached::class,
            parentColumns = ["id"],
            childColumns = ["eventId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [
        Index(value = ["normalizedName"]),
        Index(value = ["normalizedArtists"]),
        Index(value = ["normalizedPlaceName"]),
    ],
)
data class EventSearchIndexCached(
    @PrimaryKey val eventId: Int,
    val normalizedName: String,
    val normalizedArtists: String,
    val normalizedPlaceName: String,
)
