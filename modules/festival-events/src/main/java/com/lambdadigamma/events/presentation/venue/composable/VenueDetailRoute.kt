package com.lambdadigamma.events.presentation.venue.composable

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.events.presentation.venue.VenueDetailViewModel

@Composable
fun VenueDetailRoute(
    onBack: () -> Unit,
    onShowEvent: (Int) -> Unit,
    viewModel: VenueDetailViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    VenueDetailScreen(
        uiState = uiState,
        onBack = onBack,
        onShowEvent = onShowEvent,
    )
}
