package com.lambdadigamma.pages.data.remote

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.pages.data.remote.model.SomeBlockData
import com.lambdadigamma.prosemirror.Document
import kotlinx.parcelize.Parcelize

@Parcelize
data class ImageCollectionBlock(
    @SerializedName("text") val text: Document?
) : SomeBlockData {

    fun isBlank(): Boolean {
        return text?.isBlank() ?: true
    }

}