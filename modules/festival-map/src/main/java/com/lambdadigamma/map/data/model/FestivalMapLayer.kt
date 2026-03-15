package com.lambdadigamma.map.data.model

internal data class FestivalMapLayer(
    val type: FestivalMapLayerType,
    val features: List<FestivalMapFeature>,
)
