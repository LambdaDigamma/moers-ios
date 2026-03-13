package com.lambdadigamma.pages.data.local.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import java.util.Date

@Entity(tableName = "pages")
data class PageCached(
    @PrimaryKey(autoGenerate = false) val id: Int,
    var title: String? = null,
    var summary: String? = null,
    var pageTemplateID: Int? = null,
    var slug: String? = null,
    var resourceUrl: String? = null,
    var creatorID: Int? = null,
//    var extras: Map<String, String>? = null,
    var mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer(),
    var archivedAt: Date? = null,
    var createdAt: Date? = Date(),
    var updatedAt: Date? = Date()
)