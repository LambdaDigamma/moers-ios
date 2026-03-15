package com.lambdadigamma.news.presentation

import android.os.Parcelable
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.news.data.remote.model.PageId
import com.lambdadigamma.pages.data.remote.model.PageBlock
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
enum class PostType : Parcelable {
    DEFAULT,
    INSTAGRAM
}

@Parcelize
data class PostDisplayable(
    val id: Int,
    val title: String,
    val summary: String,
    val type: PostType,
    val pageId: PageId,
    var blocks: List<PageBlock> = emptyList(),
    val externalHref: String?,
    val mediaCollections: MediaCollectionsContainer,
    val publishedAt: Date?
) : Parcelable {


}
