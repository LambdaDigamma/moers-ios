package com.lambdadigamma.events.presentation.detail

import android.os.Parcelable
import com.lambdadigamma.core.geo.Point
import kotlinx.parcelize.Parcelize

@Parcelize
data class PlaceDisplayable(
    val id: Long,
    val name: String,
    val point: Point,
    val addressLine1: String,
    val addressLine2: String,
): Parcelable