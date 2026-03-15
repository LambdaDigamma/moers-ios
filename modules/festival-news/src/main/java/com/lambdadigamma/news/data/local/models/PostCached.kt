package com.lambdadigamma.news.data.local.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import java.util.Date

@Entity(tableName = "posts")
data class PostCached(
    @PrimaryKey var id: Int = 0,
    var title: String,
    var summary: String,
    var feedId: Int,
    var pageId: Int,
    var vimeoId: String,
    var publication: String,
    var externalHref: String,
    var extras: PostExtras? = null,
    var mediaCollections: MediaCollectionsContainer,
    var publishedAt: Date?,
    var createdAt: Date?,
    var updatedAt: Date?,
    var deletedAt: Date?,
) {

}