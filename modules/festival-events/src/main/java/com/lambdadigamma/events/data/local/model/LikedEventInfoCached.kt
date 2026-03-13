package com.lambdadigamma.events.data.local.model

import androidx.room.Embedded
import androidx.room.Relation

class LikedEventInfoCached(
    @Embedded val event: EventCached,

    @Relation(
        parentColumn = "placeId",
        entityColumn = "id"
    )
    val place: PlaceCached?,

    @Relation(
        parentColumn = "id",
        entityColumn = "eventId",
        entity = LikedEventCached::class
    )
    val favoriteEvent: LikedEventCached?
)