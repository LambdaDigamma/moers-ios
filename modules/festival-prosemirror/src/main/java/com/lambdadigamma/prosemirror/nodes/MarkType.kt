package com.lambdadigamma.prosemirror.nodes

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class MarkLinkAttributes(val href: String): Parcelable

@Parcelize
sealed class MarkType: Parcelable {

    object Bold : MarkType()
    object Italic : MarkType()
    object Underline : MarkType()
    object Strike : MarkType()
    object Superscript : MarkType()
    data class Link(val attrs: MarkLinkAttributes?) : MarkType()

    companion object {
        const val boldType = "bold"
        const val italicType = "italic"
        const val underlineType = "underline"
        const val strikeType = "strike"
        const val superscriptType = "superscript"
        const val linkType = "link"
    }

}