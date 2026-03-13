package com.lambdadigamma.map.data.di

import com.google.gson.annotations.SerializedName

data class FGDCollection(
    @SerializedName("camping")
    val campingFeatures: List<String>,
) {

    object Layers {
        const val Camping = "camping"
        const val Dorf = "dorf"
        const val MedicalService = "medical_service"
        const val Stages = "stages"
        const val Surfaces = "surfaces"
        const val Tickets = "tickets"
        const val Toilets = "toilets"
        const val Transportation = "transportation"

        fun getAll(): List<String> {
            return listOf(
                Camping,
                Dorf,
                MedicalService,
                Stages,
                Surfaces,
                Tickets,
                Toilets,
                Transportation,
            )
        }
    }

}
