package com.lambdadigamma.pages.data.remote

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.pages.data.remote.model.SomeBlockData
import com.lambdadigamma.prosemirror.Document
import kotlinx.parcelize.Parcelize

@Parcelize
data class YoutubeVideoBlock(
    @SerializedName("title") val title: String? = null,
    @SerializedName("video_id") val videoId: String? = null,
    @SerializedName("text") val text: Document? = null,
) : SomeBlockData {

    fun isBlank(): Boolean {
        return title.isNullOrBlank() &&
            videoId.isNullOrBlank() &&
            (text?.isBlank() ?: true)
    }
}
