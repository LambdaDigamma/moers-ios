package com.lambdadigamma.news.data.remote.model

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.events.data.local.model.EventExtras
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.news.data.local.models.PostExtras
import com.lambdadigamma.pages.data.remote.model.Page
import java.util.Date

typealias PostId = Int
typealias FeedId = Int
typealias PageId = Int

data class Post(
    @SerializedName("id") val id: PostId,
    @SerializedName("title") val title: String,
    @SerializedName("summary") val summary: String,
    @SerializedName("feed_id") val feedId: FeedId,
    @SerializedName("page_id") var pageId: PageId,
    @SerializedName("external_href") var externalHref: String? = null,
    @SerializedName("media_collections") var mediaCollections: MediaCollectionsContainer? = null,
    @SerializedName("created_at") var createdAt: Date? = null,
    @SerializedName("updated_at") var updatedAt: Date? = null,
    @SerializedName("published_at") var publishedAt: Date? = null,
    @SerializedName("page") var page: Page? = null,
    var extras: PostExtras? = null,
) {

    companion object Factory {
        fun stub(id: PostId) : Post {
            return Post(
                id = id,
                title = "Post #1",
                summary = "Short summary goes here.",
                feedId = 1,
                pageId = 1
            )
        }
    }

}