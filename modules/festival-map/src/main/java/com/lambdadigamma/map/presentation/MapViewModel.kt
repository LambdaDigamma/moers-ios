package com.lambdadigamma.map.presentation

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.core.extensions.resultOf
import com.lambdadigamma.map.data.di.FGDLoader
import com.lambdadigamma.map.data.di.MapModule
import com.lambdadigamma.map.data.local.GeoDataLayerDatabase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import javax.inject.Inject

@HiltViewModel
class MapViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    eventsInitialState: MapUiState
): BaseViewModel<MapUiState, MapUiState.PartialState, MapEvents, MapIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventsInitialState,
) {

    init {
        acceptIntent(MapIntent.Refresh)
        acceptIntent(MapIntent.GetData)
    }

    override fun mapIntents(intent: MapIntent): Flow<MapUiState.PartialState> {

        when (intent) {
            is MapIntent.GetData -> {
                return flow {

                }
            }
            is MapIntent.Refresh -> {

                return flow {
//                    FGDLoader(db = MapModule.provideGeoDataLayerDatabase()).load("surfaces")
                }

            }
        }
    }

    override fun reduceUiState(
        previousState: MapUiState,
        partialState: MapUiState.PartialState
    ): MapUiState {
        TODO("Not yet implemented")
    }

}