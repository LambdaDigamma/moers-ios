package com.lambdadigamma.map.presentation

import com.lambdadigamma.map.data.model.FestivalMapCoordinate
import com.lambdadigamma.map.data.model.FestivalMapFeature
import com.lambdadigamma.map.data.model.FestivalMapGeometry
import com.lambdadigamma.map.data.model.FestivalMapPlace

internal sealed interface MapSelection {
    val stableId: String

    fun focusPoint(): FestivalMapCoordinate

    data class Feature(val value: FestivalMapFeature) : MapSelection {
        override val stableId: String = "feature:${value.id}"

        override fun focusPoint(): FestivalMapCoordinate = value.geometry.focusPoint()
    }

    data class Place(val value: FestivalMapPlace) : MapSelection {
        override val stableId: String = "place:${value.id}"

        override fun focusPoint(): FestivalMapCoordinate = value.point
    }
}

private fun FestivalMapGeometry.focusPoint(): FestivalMapCoordinate {
    val allPoints = when (this) {
        is FestivalMapGeometry.Polygon -> rings.flatten()
        is FestivalMapGeometry.MultiPolygon -> polygons.flatten().flatten()
    }

    val latitude = allPoints.map { it.latitude }.average()
    val longitude = allPoints.map { it.longitude }.average()

    return FestivalMapCoordinate(
        latitude = latitude,
        longitude = longitude,
    )
}
