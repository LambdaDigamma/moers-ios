package com.lambdadigamma.map.presentation.composable

import androidx.compose.runtime.Composable
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.map.presentation.MapScreen
import com.lambdadigamma.map.presentation.MapViewModel

@Composable
internal fun MapRoute(
    onShowEvent: (Int) -> Unit,
    viewModel: MapViewModel = hiltViewModel(),
) {
    val uiState = viewModel.uiState.collectAsStateWithLifecycle()

    MapScreen(
        uiState = uiState.value,
        onIntent = viewModel::acceptIntent,
        onShowEvent = onShowEvent,
    )
}
