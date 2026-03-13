package com.lambdadigamma.prosemirror.nodes

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
data class ParagraphAttributes(
    @SerializedName("textAlign") val textAlignment: TextAlignment = TextAlignment.LEFT,
): Parcelable