package com.lambdadigamma.events.data.local.model

import androidx.room.ColumnInfo
import androidx.room.Embedded
import androidx.room.Relation
import com.lambdadigamma.pages.data.local.model.PageCached

data class EventWithPlaceAndPageCached(
    @Embedded val event: EventCached,

    @Relation(
        parentColumn = "placeId",
        entityColumn = "id"
    )
    val place: PlaceCached?,

    @Relation(
        parentColumn = "pageId",
        entityColumn = "id"
    )
    val page: PageCached?,

    @Relation(
        parentColumn = "id",
        entityColumn = "eventId",
        entity = LikedEventCached::class
    )
    val favoriteEvent: LikedEventCached?,

    @ColumnInfo(name = "isLiked")
    val isLiked: Boolean
)