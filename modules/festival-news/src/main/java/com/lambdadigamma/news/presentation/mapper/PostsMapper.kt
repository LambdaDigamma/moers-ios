package com.lambdadigamma.news.presentation.mapper

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.domain.models.EventDetailData
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.EventDetailDisplayable
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.news.data.remote.model.Post
import com.lambdadigamma.news.presentation.PostDisplayable
import com.lambdadigamma.news.presentation.PostType

fun Post.toPresentationModel() = PostDisplayable(
    id = id,
    title = title,
    summary = summary,
    pageId = pageId,
    blocks = page?.blocks ?: emptyList(),
    mediaCollections = mediaCollections ?: MediaCollectionsContainer(),
    type = if (extras?.type == "instagram") PostType.INSTAGRAM else PostType.DEFAULT,
    externalHref = externalHref,
    publishedAt = publishedAt
)


