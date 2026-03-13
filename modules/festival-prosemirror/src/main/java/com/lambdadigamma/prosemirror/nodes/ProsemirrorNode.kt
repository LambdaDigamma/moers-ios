package com.lambdadigamma.prosemirror.nodes

import android.os.Parcelable

interface ProsemirrorNode: Parcelable {

    val type: String
    val content: List<ProsemirrorNode>?

    fun isBlank(): Boolean {
        return content.isNullOrEmpty() || content?.map { it.isBlank() }?.all { it } ?: true
    }

}