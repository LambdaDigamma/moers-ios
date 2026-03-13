package com.lambdadigamma.pages.data.mapper

import com.lambdadigamma.pages.data.local.model.PageCached
import com.lambdadigamma.pages.data.remote.model.Page

fun PageCached.toDomainModel() = Page(
    id = id,
    title = title,
    summary = summary,
    pageTemplateID = pageTemplateID,
    slug = slug,
    resourceUrl = resourceUrl,
    creatorID = creatorID,
//    extras = extras,
    mediaCollections = mediaCollections,
    archivedAt = archivedAt,
    createdAt = createdAt,
    updatedAt = updatedAt,
)

fun Page.toEntityModel() = PageCached(
    id = id,
    title = title,
    summary = summary,
    pageTemplateID = pageTemplateID,
    slug = slug,
    resourceUrl = resourceUrl,
    creatorID = creatorID,
//    extras = extras,
    mediaCollections = mediaCollections,
    archivedAt = archivedAt,
    createdAt = createdAt,
    updatedAt = updatedAt,
)