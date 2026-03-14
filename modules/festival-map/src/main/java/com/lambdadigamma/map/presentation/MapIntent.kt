package com.lambdadigamma.map.presentation

import com.lambdadigamma.map.data.model.FestivalMapFeature

internal sealed class MapIntent {
    data object Load : MapIntent()

    data object Refresh : MapIntent()

    data class SelectFeature(val feature: FestivalMapFeature) : MapIntent()

    data object ClearSelection : MapIntent()
}
