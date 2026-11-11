package com.lambdadigamma.rubbish

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.google.gson.annotations.SerializedName

enum class RubbishWasteType(val value: String) {
    @SerializedName("residual")
    RESIDUAL("residual"),

    @SerializedName("organic")
    ORGANIC("organic"),

    @SerializedName("paper")
    PAPER("paper"),

    @SerializedName("plastic")
    PLASTIC("plastic"),

    @SerializedName("cuttings")
    CUTTINGS("cuttings");

    companion object {
        fun fromString(value: String): RubbishWasteType? = entries.firstOrNull { it.value == value }
    }
}

@StringRes
fun RubbishWasteType.labelRes(): Int = when (this) {
    RubbishWasteType.RESIDUAL -> R.string.rubbish_type_residual
    RubbishWasteType.ORGANIC -> R.string.rubbish_type_organic
    RubbishWasteType.PAPER -> R.string.rubbish_type_paper
    RubbishWasteType.PLASTIC -> R.string.rubbish_type_plastic
    RubbishWasteType.CUTTINGS -> R.string.rubbish_type_cuttings
}

@DrawableRes
fun RubbishWasteType.icon(): Int = when (this) {
    RubbishWasteType.RESIDUAL -> R.drawable.ic_rubbish_residual
    RubbishWasteType.ORGANIC -> R.drawable.ic_rubbish_organic
    RubbishWasteType.PAPER -> R.drawable.ic_rubbish_paper
    RubbishWasteType.PLASTIC -> R.drawable.ic_rubbish_plastic
    RubbishWasteType.CUTTINGS -> R.drawable.ic_rubbish_organic
}
