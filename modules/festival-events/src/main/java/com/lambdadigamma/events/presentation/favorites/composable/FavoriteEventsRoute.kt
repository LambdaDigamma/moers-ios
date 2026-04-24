package com.lambdadigamma.events.presentation.favorites.composable

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsEvents
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsViewModel

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun FavoriteEventsRoute(
    viewModel: FavoriteEventsViewModel = hiltViewModel(),
    onShowEvent: (Int) -> Unit,
    onShowTimetable: () -> Unit,
) {

    val uiState by viewModel.uiState
        .collectAsStateWithLifecycle()

    FavoriteEventsScreen(
        uiState = uiState,
        onIntent = viewModel::acceptIntent,
        onShowTimetable = onShowTimetable,
    )

    viewModel.event.collectWithLifecycle {
        when (it) {
            is FavoriteEventsEvents.ShowEvent -> {
                onShowEvent(it.id)
            }
        }
    }

}
