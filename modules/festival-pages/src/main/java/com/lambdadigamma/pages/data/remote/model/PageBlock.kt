package com.lambdadigamma.pages.data.remote.model

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class PageBlock(
    @SerializedName("id") val id: Int,
    @SerializedName("page_id") var pageID: Int?,
    @SerializedName("type") var type: String,
    @SerializedName("data") var data: SomeBlockData,
    @SerializedName("order") var order: Int,
    @SerializedName("children") var children: List<PageBlock> = emptyList(),
    @SerializedName("media_collections") var mediaCollections: MediaCollectionsContainer?,
    @SerializedName("created_at") var createdAt: Date?,
    @SerializedName("updated_at") var updatedAt: Date?,
    val blockType: BlockType
): Parcelable