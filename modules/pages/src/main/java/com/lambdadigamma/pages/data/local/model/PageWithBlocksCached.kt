package com.lambdadigamma.pages.data.local.model

import androidx.room.Embedded
import androidx.room.Relation

data class PageWithBlocksCached(
    @Embedded val page: PageCached,
    @Relation(
        parentColumn = "id",
        entityColumn = "pageID"
    )
    val blocks: List<PageBlockCached>
)