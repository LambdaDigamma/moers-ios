package com.lambdadigamma.events.presentation.timetable.composable

import android.text.format.DateUtils
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ScrollableTabRow
import androidx.compose.material3.Tab
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableUiState
import kotlinx.coroutines.launch

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun TimetableContent(
    modifier: Modifier = Modifier,
    uiState: TimetableUiState,
    onIntent: (TimetableIntent) -> Unit,
    pagerState: PagerState,
    currentIndex: MutableState<Int>
) {

    val coroutineScope = rememberCoroutineScope()
    val localContext = LocalContext.current
    val undatedTitle = stringResource(R.string.no_time_yet)
    val selectedIndex = currentIndex.value.coerceIn(0, uiState.data.sections.lastIndex.coerceAtLeast(0))

    val titles = uiState.data.sections.map { timetableSection ->
        if (timetableSection.isUndated || timetableSection.range == null) {
            undatedTitle
        } else {
            DateUtils.formatDateTime(
                localContext,
                timetableSection.range.first.time,
                DateUtils.FORMAT_SHOW_WEEKDAY
            )
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize(),
    ) {
        if (titles.isNotEmpty()) {
            ScrollableTabRow(
                selectedTabIndex = selectedIndex,
                edgePadding = 0.dp
            ) {
                titles.forEachIndexed { index, title ->
                    Tab(
                        selected = selectedIndex == index,
                        onClick = {
                            println("SELECTED SECTION: $index")
                            currentIndex.value = index
//                        onIntent(TimetableIntent.SelectedSection(index))
//                        coroutineScope.launch {

//                            pagerState.scrollToPage(index)
//                        }

//                        coroutineScope.launch {
//                            pagerState.animateScrollToPage(index)
//                        }
                        },
                        text = { Text(title) }
                    )
                }
            }
        }

        SwipeRefresh(
            state = rememberSwipeRefreshState(uiState.isLoading),
            onRefresh = { onIntent(TimetableIntent.RefreshEvents) },
            modifier = Modifier
                .fillMaxSize(),
        ) {

//            Text(text = uiState.toString())

            if (uiState.data.sections.isNotEmpty()) {

                if (uiState.data.sections[selectedIndex].events.isNotEmpty()) {

                    LazyColumn(
                        modifier = Modifier
                            .fillMaxSize(),
                        content = {

                            items(
                                items = uiState.data.sections[selectedIndex].events,
                                key = { event -> event.id },
                            ) { item ->
                                EventItem(event = item, onEventClick = { onIntent(TimetableIntent.EventClicked(item.id)) })
                            }

                        })

                } else {

                    Box(
                        modifier = Modifier
                            .verticalScroll(rememberScrollState())
                            .fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
//                    Text(
//                        text = "Neu laden",
//                        style = MaterialTheme.typography.bodyMedium
//                    )
                    }

                }

            } else {

                if (uiState.isLoading) {
                    TimetableLoading()
                } else {
                    if (uiState.isError != null) {
                        TimetableError(
                            modifier = Modifier.fillMaxSize(),
                            throwable = uiState.isError,
                            onRefresh = { onIntent(TimetableIntent.RefreshEvents) }
                        )
                    }
                }

            }

        }

    }

}
