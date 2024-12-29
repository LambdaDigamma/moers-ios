package com.lambdadigamma.fuel.data

data class FuelStationDetailRequestResponse(
    val ok: Boolean,
    val license: String,
    val data: String,
    val status: String,
    val station: FuelStation
)