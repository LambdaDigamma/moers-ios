package com.lambdadigamma.prosemirror.nodes

import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeOrderedList(
    override val type: String = Companion.type,
    override val content: List<ProsemirrorNode>?,
): NodeList {

    companion object {
        const val type = "orderedList"
    }

}