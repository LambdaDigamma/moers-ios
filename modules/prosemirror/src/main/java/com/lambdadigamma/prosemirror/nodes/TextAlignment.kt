package com.lambdadigamma.prosemirror.nodes

import com.google.gson.annotations.SerializedName

enum class TextAlignment {
    @SerializedName("left")
    LEFT,
    @SerializedName("right")
    RIGHT,
    @SerializedName("center")
    CENTER,
    @SerializedName("justify")
    JUSTIFY
}