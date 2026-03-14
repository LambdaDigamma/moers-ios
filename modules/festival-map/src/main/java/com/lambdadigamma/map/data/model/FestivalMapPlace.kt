package com.lambdadigamma.map.data.model

internal data class FestivalMapPlace(
    val id: Long,
    val name: String,
    val point: FestivalMapCoordinate,
    val addressLine1: String,
    val addressLine2: String,
)
