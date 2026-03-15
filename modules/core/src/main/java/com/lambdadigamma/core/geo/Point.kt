package com.lambdadigamma.core.geo

import android.location.Location
import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Point(val latitude: Double, val longitude: Double) : Parcelable

fun Location.toPoint() = Point(latitude = latitude, longitude = longitude)
