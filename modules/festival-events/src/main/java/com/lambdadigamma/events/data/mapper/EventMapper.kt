package com.lambdadigamma.events.data.mapper

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.data.local.model.EventCached

fun EventCached.toDomainModel() = Event(
    id = id,
    name = name,
    startDate = startDate,
    endDate = endDate,
    pageId = pageId,
    placeId = placeId,
    url = url,
    category = category,
    collection = collection,
    extras = extras,
    publishedAt = publishedAt,
    cancelledAt = cancelledAt,
    scheduledAt = scheduledAt,
    createdAt = createdAt,
    updatedAt = updatedAt,
    archivedAt = archivedAt,
    deletedAt = deletedAt,
    artists = artists,
    mediaCollections = mediaCollections,
)

fun Event.toEntityModel() = EventCached(
    id = id,
    name = name,
    startDate = startDate,
    endDate = endDate,
    pageId = pageId,
    placeId = placeId,
    url = url,
    category = category,
    collection = collection,
    extras = extras,
    publishedAt = publishedAt,
    cancelledAt = cancelledAt,
    scheduledAt = scheduledAt,
    createdAt = createdAt,
    updatedAt = updatedAt,
    archivedAt = archivedAt,
    deletedAt = deletedAt,
    artists = artists,
    mediaCollections = mediaCollections,
)
