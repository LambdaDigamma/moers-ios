package com.lambdadigamma.prosemirror.nodes

import kotlinx.parcelize.Parcelize

@Parcelize
data class NodeBulletList(
    override val type: String = Companion.type,
    override val content: List<ProsemirrorNode>?,
): NodeList {

    companion object {
        const val type = "bulletList"
    }

}