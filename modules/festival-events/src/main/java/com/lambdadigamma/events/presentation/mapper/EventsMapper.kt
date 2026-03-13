package com.lambdadigamma.events.presentation.mapper

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.domain.models.EventDetailData
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.EventDetailDisplayable

fun Event.toPresentationModel() = EventDisplayable(
    id = id,
    name = name,
    startDate = startDate,
    endDate = endDate,
    isOpenEnd = isOpenEnd,
    place = place?.toPresentationModel(),
    isFavorite = isFavorite == true
)

fun Event.toDetailPresentationModel() = EventDetailDisplayable(
    id = id,
    title = name,
    startDate = startDate,
    endDate = endDate,
    artists = artists.orEmpty(),
    mediaCollections = mediaCollections,
    place = place?.toPresentationModel(),
    isFavorite = isFavorite == true,
    isOpenEnd = isOpenEnd
)

fun EventDetailData.toPresentationModel() = EventDetailDisplayable(
    id = event.id,
    title = event.name,
    startDate = event.startDate,
    endDate = event.endDate,
    artists = event.artists.orEmpty(),
    mediaCollections = event.mediaCollections,
    blocks = page?.blocks.orEmpty(),
    place = event.place?.toPresentationModel(),
    isOpenEnd = event.isOpenEnd,
    isFavorite = this.isFavorite
)