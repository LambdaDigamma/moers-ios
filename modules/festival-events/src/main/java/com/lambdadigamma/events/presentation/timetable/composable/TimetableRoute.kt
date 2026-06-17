package com.lambdadigamma.events.presentation.timetable.composable

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle
import com.lambdadigamma.core.refresh.RefreshFailureMessageFormatter
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.timetable.TimetableEvents
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableViewModel

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun TimetableRoute(
    viewModel: TimetableViewModel = hiltViewModel(),
    onShowEvent: (Int) -> Unit,
    onShowSearch: () -> Unit,
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
    val context = LocalContext.current
    val snackbarHostState = remember { SnackbarHostState() }
    val retryActionLabel = stringResource(R.string.timetable_retry)

    LaunchedEffect(key1 = "reloadTimetableDatabase", block = {
        viewModel.acceptIntent(TimetableIntent.RefreshEvents)
    })

    val uiState by viewModel.uiState
        .collectAsStateWithLifecycle()

    TimetableScreen(
        uiState = uiState,
        onIntent = viewModel::acceptIntent,
        onShowSearch = onShowSearch,
        onShowDownload = onShowDownload,
        pagerState = pagerState,
        currentIndex = currentIndex,
        snackbarHostState = snackbarHostState,
    )

    viewModel.event.collectWithLifecycle {
        when (it) {
            is TimetableEvents.ShowEvent -> {
                onShowEvent(it.id)
            }
            is TimetableEvents.ShowRefreshError -> {
                val result = snackbarHostState.showSnackbar(
                    message = RefreshFailureMessageFormatter.format(
                        context = context,
                        throwable = it.throwable,
                        lastSuccessfulRefresh = it.lastSuccessfulRefresh,
                    ),
                    actionLabel = retryActionLabel,
                )
                if (result == SnackbarResult.ActionPerformed) {
                    viewModel.acceptIntent(TimetableIntent.RefreshEvents)
                }
            }
        }
    }

}
