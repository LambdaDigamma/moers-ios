package com.lambdadigamma.events.data.local.model

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "favorite_events",
    indices = [
        Index(
            value = ["eventId"],
            unique = true
        )
    ],
    foreignKeys = [
        ForeignKey(
            entity = EventCached::class,
            parentColumns = ["id"],
            childColumns = ["eventId"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class FavoriteEventCached(
    @PrimaryKey(autoGenerate = true)
    val id: Int? = null,
    val eventId: Int
)