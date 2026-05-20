package com.lambdadigamma.events.presentation.search

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle

@Composable
fun EventSearchRoute(
    onBack: () -> Unit,
    onShowEvent: (Int) -> Unit,
    viewModel: EventSearchViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    EventSearchScreen(
        uiState = uiState,
        onIntent = viewModel::acceptIntent,
        onBack = onBack,
    )

    viewModel.event.collectWithLifecycle {
        when (it) {
            is EventSearchShowEvent -> onShowEvent(it.id)
        }
    }
}
