package com.lambdadigamma.prosemirror

import android.os.Parcelable
import com.lambdadigamma.prosemirror.nodes.ProsemirrorNode
import kotlinx.parcelize.Parcelize

@Parcelize
data class Document(
    override val type: String = Document.type,
    override var content: List<ProsemirrorNode> = listOf()
): ProsemirrorNode, Parcelable {

    companion object {
        const val type = "doc"
    }

    override fun isBlank(): Boolean {
        return content.isEmpty() || content.map { it.isBlank() }.all { it }
    }

}