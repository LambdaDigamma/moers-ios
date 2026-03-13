package com.lambdadigamma.map.presentation

sealed class MapIntent {
    data object GetData : MapIntent()

    data object Refresh : MapIntent()

}
