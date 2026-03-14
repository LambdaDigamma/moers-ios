package com.lambdadigamma.map.data.model

internal sealed interface FestivalMapGeometry {

    data class Polygon(
        val rings: List<List<FestivalMapCoordinate>>,
    ) : FestivalMapGeometry

    data class MultiPolygon(
        val polygons: List<List<List<FestivalMapCoordinate>>>,
    ) : FestivalMapGeometry
}
