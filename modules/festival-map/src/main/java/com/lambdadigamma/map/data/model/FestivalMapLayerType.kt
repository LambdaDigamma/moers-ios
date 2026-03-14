package com.lambdadigamma.map.data.model

import androidx.annotation.RawRes
import androidx.annotation.StringRes
import com.lambdadigamma.map.R

internal enum class FestivalMapLayerType(
    val remoteKey: String,
    @param:RawRes val assetResId: Int,
    @param:StringRes val labelResId: Int,
    val zIndex: Float,
) {
    Surfaces(
        remoteKey = "surfaces",
        assetResId = R.raw.surfaces,
        labelResId = R.string.map_layer_surfaces,
        zIndex = 0f,
    ),
    Camping(
        remoteKey = "camping",
        assetResId = R.raw.camping,
        labelResId = R.string.map_layer_camping,
        zIndex = 1f,
    ),
    Stages(
        remoteKey = "stages",
        assetResId = R.raw.stages,
        labelResId = R.string.map_layer_stages,
        zIndex = 2f,
    ),
    Transportation(
        remoteKey = "transportation",
        assetResId = R.raw.transportation,
        labelResId = R.string.map_layer_transportation,
        zIndex = 3f,
    ),
    MedicalService(
        remoteKey = "medical_service",
        assetResId = R.raw.medical_service,
        labelResId = R.string.map_layer_medical_service,
        zIndex = 4f,
    ),
    Tickets(
        remoteKey = "tickets",
        assetResId = R.raw.tickets,
        labelResId = R.string.map_layer_tickets,
        zIndex = 5f,
    ),
    Toilets(
        remoteKey = "toilets",
        assetResId = R.raw.toilets,
        labelResId = R.string.map_layer_toilets,
        zIndex = 6f,
    ),
    Dorf(
        remoteKey = "dorf",
        assetResId = R.raw.dorf,
        labelResId = R.string.map_layer_dorf,
        zIndex = 7f,
    ),
    ;

    companion object {
        val ordered = listOf(
            Surfaces,
            Camping,
            Stages,
            Transportation,
            MedicalService,
            Tickets,
            Toilets,
            Dorf,
        )
    }
}
