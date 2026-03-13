package com.lambdadigamma.pages.data.local.model

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import java.util.Date

@Entity(
    tableName = "page_blocks",
    indices = [Index(value = ["pageID"])],
    foreignKeys = [
        ForeignKey(
            entity = PageCached::class,
            parentColumns = ["id"],
            childColumns = ["pageID"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
class PageBlockCached(
    @PrimaryKey val id: Int,
    var pageID: Int?,
    var type: String,
    var data: String,
    @ColumnInfo(name = "order", defaultValue = "0")
    val order: Int = 0,
    var mediaCollectionsContainer: MediaCollectionsContainer?,
    var createdAt: Date?,
    var updatedAt: Date?,
)