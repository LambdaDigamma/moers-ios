package com.lambdadigamma.events.presentation.detail.composable

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.events.presentation.detail.EventDetailViewModel

@Composable
fun EventDetailRoute(
    viewModel: EventDetailViewModel = hiltViewModel(),
    onBack: () -> Unit
) {

    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    EventDetailScreen(
        uiState = uiState,
        onBack = onBack,
        onToggleLike = { viewModel.toggleFavorite() },
        onIntent = viewModel::acceptIntent
    )

}

