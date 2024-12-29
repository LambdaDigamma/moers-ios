package com.lambdadigamma.core.geo

import android.location.Location

data class Point(val latitude: Double, val longitude: Double)

fun Location.toPoint() = Point(latitude = latitude, longitude = longitude)