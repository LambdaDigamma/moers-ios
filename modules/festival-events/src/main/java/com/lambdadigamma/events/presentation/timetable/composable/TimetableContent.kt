package com.lambdadigamma.events.presentation.timetable.composable

import android.text.format.DateUtils
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.FilterList
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SecondaryScrollableTabRow
import androidx.compose.material3.Surface
import androidx.compose.material3.Tab
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableUiState

@OptIn(ExperimentalFoundationApi::class, ExperimentalMaterial3Api::class)
@Composable
fun TimetableContent(
    modifier: Modifier = Modifier,
    uiState: TimetableUiState,
    onIntent: (TimetableIntent) -> Unit,
    pagerState: PagerState,
    currentIndex: MutableState<Int>
) {

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
        if (!uiState.data.filter.isEmpty) {
            ActiveTimetableFilterBar(
                showOnlyFavorites = uiState.data.filter.showOnlyFavorites,
                selectedVenueCount = uiState.data.filter.venueIds.size,
                onClearFilter = { onIntent(TimetableIntent.ClearFilter) },
            )
        }

        if (titles.isNotEmpty()) {
            SecondaryScrollableTabRow(
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

        PullToRefreshBox(
            isRefreshing = uiState.isLoading,
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
                    } else if (uiState.data.hasAnyEvents) {
                        EmptyFilteredTimetableState(
                            onClearFilter = { onIntent(TimetableIntent.ClearFilter) },
                        )
                    }
                }

            }

        }

    }

}

@Composable
private fun ActiveTimetableFilterBar(
    showOnlyFavorites: Boolean,
    selectedVenueCount: Int,
    onClearFilter: () -> Unit,
) {
    Surface(
        color = MaterialTheme.colorScheme.secondaryContainer,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = Icons.Rounded.FilterList,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(20.dp),
            )

            Spacer(modifier = Modifier.size(10.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = stringResource(R.string.timetable_filter_active),
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                )
                Text(
                    text = when {
                        showOnlyFavorites && selectedVenueCount > 0 -> stringResource(
                            R.string.timetable_filter_active_favorites_and_venues,
                            selectedVenueCount,
                        )
                        showOnlyFavorites -> stringResource(R.string.timetable_filter_active_favorites)
                        else -> stringResource(
                            R.string.timetable_filter_active_venues,
                            selectedVenueCount,
                        )
                    },
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.8f),
                )
            }

            TextButton(onClick = onClearFilter) {
                Text(text = stringResource(R.string.favorites_clear_filter))
            }
        }
    }
}

@Composable
private fun EmptyFilteredTimetableState(
    onClearFilter: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            imageVector = Icons.Rounded.FilterList,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
        )
        Spacer(modifier = Modifier.size(12.dp))
        Text(
            text = stringResource(R.string.no_events_for_filter),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
        )
        Spacer(modifier = Modifier.size(8.dp))
        Text(
            text = stringResource(R.string.no_events_for_filter_hint),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(modifier = Modifier.size(16.dp))
        TextButton(onClick = onClearFilter) {
            Text(text = stringResource(R.string.favorites_clear_filter))
        }
    }
}
