package com.lambdadigamma.prosemirror.nodes

import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeParagraph(
    override val type: String = Companion.type,
    override val content: List<ProsemirrorNode>? = listOf(),
    @SerializedName("attrs") val attributes: ParagraphAttributes? = null
): ProsemirrorNode {

    companion object {
        const val type = "paragraph"
    }

}