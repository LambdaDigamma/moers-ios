package com.lambdadigamma.prosemirror.nodes

import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeHorizontalRule(
    override val type: String = Companion.type,
    override val content: List<ProsemirrorNode>? = null
): ProsemirrorNode {

    companion object {
        const val type = "horizontalRule"
    }

}