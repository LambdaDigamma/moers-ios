package com.lambdadigamma.core.geo

import com.google.gson.annotations.SerializedName

data class GeoJsonPoint(
    @SerializedName("type") val type: String,
    @SerializedName("coordinates") val coordinates: List<Double>
) {

    constructor(latitude: Double, longitude: Double) : this(
        "Point",
        listOf(longitude, latitude)
    )

    companion object {
        fun from(point: Point): GeoJsonPoint {
            return GeoJsonPoint("Point", listOf(point.longitude, point.latitude))
        }
    }

    fun toPoint(): Point {
        return Point(latitude = coordinates[1], longitude = coordinates[0])
    }
}