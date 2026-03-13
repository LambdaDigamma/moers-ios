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
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
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
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState
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

    val titles = uiState.data.sections.map { timetableSection ->
        DateUtils.formatDateTime(
            localContext,
            timetableSection.range.first.time,
            DateUtils.FORMAT_SHOW_WEEKDAY
        )
    }

    Column(
        modifier = modifier
            .fillMaxSize(),
    ) {
        TabRow(
            selectedTabIndex = currentIndex.value,
        ) {
            titles.forEachIndexed { index, title ->
                Tab(
                    selected = currentIndex.value == index,
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

        SwipeRefresh(
            state = rememberSwipeRefreshState(uiState.isLoading),
            onRefresh = { onIntent(TimetableIntent.RefreshEvents) },
            modifier = Modifier
                .fillMaxSize(),
        ) {

//            Text(text = uiState.toString())

            if (uiState.data.sections.isNotEmpty()) {


                if (uiState.data.sections[currentIndex.value].events.isNotEmpty()) {

                    LazyColumn(
                        modifier = Modifier
                            .fillMaxSize(),
                        content = {

                            items(
                                items = uiState.data.sections[currentIndex.value].events,
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