package com.lambdadigamma.map.presentation.composable

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.map.presentation.MapScreen
import com.lambdadigamma.map.presentation.MapViewModel

@Composable
fun MapRoute(
//    viewModel: MapViewModel = hiltViewModel()
) {

//    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

//    MapScreen(
//        uiState = uiState
//    )
    BasicMapImage()

}