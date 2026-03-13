package com.lambdadigamma.events.presentation.favorites.composable

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsEvents
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsIntent
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsViewModel
import com.lambdadigamma.events.presentation.timetable.TimetableEvents
import com.lambdadigamma.events.presentation.timetable.TimetableViewModel

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun FavoriteEventsRoute(
    viewModel: FavoriteEventsViewModel = hiltViewModel(),
    onShowEvent: (Int) -> Unit,
) {

    val uiState by viewModel.uiState
        .collectAsStateWithLifecycle()

    FavoriteEventsScreen(
        uiState = uiState,
        onIntent = viewModel::acceptIntent,
    )

    viewModel.event.collectWithLifecycle {
        when (it) {
            is FavoriteEventsEvents.ShowEvent -> {
                onShowEvent(it.id)
            }
        }
    }

}