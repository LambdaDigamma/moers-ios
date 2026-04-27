package com.lambdadigamma.events.presentation.venue.composable

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.events.presentation.venue.VenueDetailUiState
import com.lambdadigamma.events.presentation.venue.VenueDetailViewModel

@Composable
fun VenueDetailRoute(
    placeId: Long,
    onBack: () -> Unit,
    onShowEvent: (Int) -> Unit,
) {
    VenueDetailStateProvider(placeId = placeId) { uiState ->
        VenueDetailScreen(
            uiState = uiState,
            onBack = onBack,
            onShowEvent = onShowEvent,
        )
    }
}

@Composable
fun VenueDetailStateProvider(
    placeId: Long,
    content: @Composable (uiState: VenueDetailUiState) -> Unit,
) {
    val viewModel: VenueDetailViewModel = hiltViewModel<VenueDetailViewModel, VenueDetailViewModel.Factory>(
        key = "venue-detail-$placeId",
        creationCallback = { factory ->
            factory.create(placeId)
        },
    )
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    content(uiState)
}
