package com.lambdadigamma.events.data.local.model

import androidx.room.Embedded
import androidx.room.Junction
import androidx.room.Relation


data class FavoriteEventInfoCached(
    @Embedded val favorite: LikedEventCached,

    @Relation(
        parentColumn = "eventId",
        entityColumn = "id",
        entity = EventCached::class
    )
    val event: LikedEventInfoCached?,
//    @Relation(
//        parentColumn = "placeId",
//        entityColumn = "id"
//    )
//    val place: PlaceCached?,
//
//    @Relation(
//        parentColumn = "id",
//        entityColumn = "eventId"
//    )
//    val favoriteEvent: FavoriteEventCached?
)