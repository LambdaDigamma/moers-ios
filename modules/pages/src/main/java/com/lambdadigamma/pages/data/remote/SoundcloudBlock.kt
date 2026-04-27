package com.lambdadigamma.pages.data.remote

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.pages.data.remote.model.SomeBlockData
import com.lambdadigamma.prosemirror.Document
import kotlinx.parcelize.Parcelize

@Parcelize
data class SoundcloudBlock(
    @SerializedName("title") val title: String? = null,
    @SerializedName("url") val url: String? = null,
    @SerializedName("track_id") val trackId: String? = null,
    @SerializedName("text") val text: Document? = null,
) : SomeBlockData {

    fun isBlank(): Boolean {
        return title.isNullOrBlank() &&
            url.isNullOrBlank() &&
            trackId.isNullOrBlank() &&
            (text?.isBlank() ?: true)
    }
}
