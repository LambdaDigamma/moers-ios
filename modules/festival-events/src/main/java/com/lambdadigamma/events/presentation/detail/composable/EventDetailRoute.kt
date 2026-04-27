package com.lambdadigamma.events.presentation.detail.composable

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.events.presentation.detail.EventDetailViewModel

@Composable
fun EventDetailRoute(
    eventId: Int,
    onBack: () -> Unit,
    onShowVenue: (Long) -> Unit,
) {
    val viewModel: EventDetailViewModel = hiltViewModel<EventDetailViewModel, EventDetailViewModel.Factory>(
        creationCallback = { factory ->
            factory.create(eventId)
        },
    )

    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    EventDetailScreen(
        uiState = uiState,
        onBack = onBack,
        onToggleLike = { viewModel.toggleFavorite() },
        onIntent = viewModel::acceptIntent,
        onShowVenue = onShowVenue,
    )

}
