package com.lambdadigamma.map.data.model

internal data class FestivalMapFeature(
    val id: String,
    val layerType: FestivalMapLayerType,
    val name: String?,
    val featureType: String?,
    val description: String?,
    val boothNumber: Int?,
    val isFood: Boolean?,
    val geometry: FestivalMapGeometry,
)
