package com.lambdadigamma.pages.data.remote

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.pages.data.remote.model.SomeBlockData
import com.lambdadigamma.prosemirror.Document
import kotlinx.parcelize.Parcelize

@Parcelize
data class TextBlock(
    @SerializedName("title") val title: String?,
    @SerializedName("subtitle") val subtitle: String?,
    @SerializedName("text") val text: Document?
) : SomeBlockData {

    fun isBlank(): Boolean {
        return title.isNullOrBlank() &&
                subtitle.isNullOrBlank() &&
                text?.isBlank() ?: true
    }

}