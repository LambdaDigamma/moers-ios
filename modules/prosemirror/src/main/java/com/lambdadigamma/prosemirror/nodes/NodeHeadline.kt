package com.lambdadigamma.prosemirror.nodes

import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeHeadline(
    override val type: String = Companion.type,
    override val content: List<ProsemirrorNode>?,
    @SerializedName("attrs") val attributes: HeadlineAttributes? = null
): ProsemirrorNode {

    companion object {
        const val type = "headline"
    }

}