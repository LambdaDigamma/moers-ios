package com.lambdadigamma.news.data.mapper

import androidx.room.PrimaryKey
import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.data.local.model.EventCached
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.news.data.local.models.PostCached
import com.lambdadigamma.news.data.remote.model.Post
import java.util.Date

fun PostCached.toDomainModel() = Post(
    id = id,
    title = title,
    summary = summary,
    feedId = feedId,
    pageId = pageId,
    mediaCollections = mediaCollections,
    externalHref = externalHref,
    extras = extras,
    createdAt = createdAt,
    updatedAt = updatedAt,
    publishedAt = publishedAt
)

fun Post.toEntityModel() = PostCached(
    id = id,
    title = title,
    summary = summary,
    feedId = feedId,
    pageId = pageId,
    vimeoId = "",
    publication = "",
    externalHref = externalHref.orEmpty(),
    extras = extras,
    mediaCollections = mediaCollections ?: MediaCollectionsContainer(),
    publishedAt = publishedAt,
    createdAt = createdAt,
    updatedAt = updatedAt,
    deletedAt = null
)
