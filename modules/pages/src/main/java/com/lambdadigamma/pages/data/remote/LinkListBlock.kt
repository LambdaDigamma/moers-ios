package com.lambdadigamma.pages.data.remote

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.pages.data.remote.model.SomeBlockData
import kotlinx.parcelize.Parcelize

@Parcelize
data class LinkListBlock(
    @SerializedName("links") val links: List<LinkEntry> = emptyList(),
) : SomeBlockData {

    @Parcelize
    data class LinkEntry(
        @SerializedName("text") val text: String,
        @SerializedName("href") val href: String,
        @SerializedName("icon") val icon: String? = null,
        @SerializedName("color") val color: String? = null,
    ) : android.os.Parcelable

    fun isBlank(): Boolean {
        return links.isEmpty()
    }
}
