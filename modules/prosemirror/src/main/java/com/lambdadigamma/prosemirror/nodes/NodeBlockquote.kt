package com.lambdadigamma.prosemirror.nodes

import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeBlockquote(
    override val type: String = Companion.type,
    override val content: List<ProsemirrorNode>?,
): ProsemirrorNode {

    companion object {
        const val type = "blockquote"
    }

}