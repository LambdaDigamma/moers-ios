package com.lambdadigamma.events.presentation.timetable.composable

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle
import com.lambdadigamma.events.presentation.timetable.TimetableEvents
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableViewModel

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun TimetableRoute(
    viewModel: TimetableViewModel = hiltViewModel(),
    onShowEvent: (Int) -> Unit,
    onShowDownload: () -> Unit,
    pagerState: PagerState = rememberPagerState(
        initialPage = 0,
        initialPageOffsetFraction = 0f,
        pageCount = { 10 }
    )
) {

    val currentIndex = rememberSaveable {
        mutableIntStateOf(0)
    }

    LaunchedEffect(key1 = "reloadTimetableDatabase", block = {
        viewModel.acceptIntent(TimetableIntent.RefreshEvents)
    })

    val uiState by viewModel.uiState
        .collectAsStateWithLifecycle()

    TimetableScreen(
        uiState = uiState,
        onIntent = viewModel::acceptIntent,
        onShowDownload = onShowDownload,
        pagerState = pagerState,
        currentIndex = currentIndex
    )

    viewModel.event.collectWithLifecycle {
        when (it) {
            is TimetableEvents.ShowEvent -> {
                onShowEvent(it.id)
            }
        }
    }

}
