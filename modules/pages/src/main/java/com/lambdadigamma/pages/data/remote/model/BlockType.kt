package com.lambdadigamma.pages.data.remote.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
sealed class BlockType(val type: String): Parcelable {

    object YoutubeVideo : BlockType("youtube-video")
    object Soundcloud : BlockType("soundcloud")
    object ExternalLink : BlockType("externalLink")
    object Text : BlockType("tip-tap-text-with-media")
    object LinkList : BlockType("link-list")
    object ImageCollection : BlockType("image-collection")
    object Unknown : BlockType("unknown")

}
