package com.lambdadigamma.events.data.local.model

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import androidx.room.Relation

@Entity(
    tableName = "liked_events",
    indices = [
        Index(
            value = ["eventId"],
            unique = true
        )
    ],
)
data class LikedEventCached(
    @PrimaryKey(autoGenerate = true)
    val id: Int? = null,
    val eventId: Int
) {
}