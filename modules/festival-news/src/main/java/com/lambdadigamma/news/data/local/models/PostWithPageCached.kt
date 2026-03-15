package com.lambdadigamma.news.data.local.models

import androidx.room.ColumnInfo
import androidx.room.Embedded
import androidx.room.Relation
import com.lambdadigamma.pages.data.local.model.PageCached
import com.lambdadigamma.pages.data.local.model.PageWithBlocksCached

data class PostWithPageCached(
    @Embedded val post: PostCached,

    @Relation(
        parentColumn = "pageId",
        entityColumn = "id"
    )
    val page: PageCached?,
)