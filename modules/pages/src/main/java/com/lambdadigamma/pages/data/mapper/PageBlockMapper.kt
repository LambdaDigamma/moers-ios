package com.lambdadigamma.pages.data.mapper

import com.lambdadigamma.pages.data.local.model.PageBlockCached
import com.lambdadigamma.pages.data.remote.model.PageBlock

fun PageBlockCached.toDomainModel(): PageBlock {

    val type = BlockDataMapper.getBlockType(type)
    val data = BlockDataMapper.fromString(data, type)

    return PageBlock(
        id = id,
        pageID = pageID,
        type = this.type,
        blockType = type,
        data = data,
        order = order,
        mediaCollections = mediaCollectionsContainer,
        createdAt = createdAt,
        updatedAt = updatedAt,
    )
}

fun PageBlock.toEntityModel(): PageBlockCached {

        val data = BlockDataMapper.toString(data, blockType)

        return PageBlockCached(
            id = id,
            pageID = pageID,
            type = type,
            data = data,
            order = order,
            mediaCollectionsContainer = mediaCollections,
            createdAt = createdAt,
            updatedAt = updatedAt,
        )
}