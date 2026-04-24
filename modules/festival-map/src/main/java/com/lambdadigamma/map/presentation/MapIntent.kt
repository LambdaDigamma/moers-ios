package com.lambdadigamma.map.presentation

import com.lambdadigamma.map.data.model.FestivalMapFeature
import com.lambdadigamma.map.data.model.FestivalMapPlace

internal sealed class MapIntent {
    data object Load : MapIntent()

    data object Refresh : MapIntent()

    data object CenterOnUserLocation : MapIntent()

    data class SelectFeature(val feature: FestivalMapFeature) : MapIntent()

    data class SelectPlace(val place: FestivalMapPlace) : MapIntent()

    data object ClearSelection : MapIntent()
}
