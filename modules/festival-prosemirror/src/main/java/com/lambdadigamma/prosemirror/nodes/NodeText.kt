package com.lambdadigamma.prosemirror.nodes

import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeText(
    @SerializedName("type") override val type: String = Companion.type,
    @SerializedName("text") val text: String,
    @SerializedName("marks") val marks: List<MarkType> = listOf(),
): ProsemirrorNode {

    override val content: List<ProsemirrorNode>?
        get() = null

    companion object {
        const val type = "text"
    }

    override fun isBlank(): Boolean {
        return text.trim().isBlank()
    }

}

