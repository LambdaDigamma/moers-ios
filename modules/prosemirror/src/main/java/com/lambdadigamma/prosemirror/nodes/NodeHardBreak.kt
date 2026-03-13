package com.lambdadigamma.prosemirror.nodes

import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeHardBreak(
    override val type: String = NodeHardBreak.type,
    override val content: List<ProsemirrorNode>? = null
): ProsemirrorNode {

    companion object {
        const val type = "hardBreak"
    }

}