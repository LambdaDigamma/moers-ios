package com.lambdadigamma.events.presentation.favorites.composable

import android.text.format.DateUtils
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.detail.composable.EventDetailLoading
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsIntent
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsUiState
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableUiState

@OptIn(ExperimentalFoundationApi::class, ExperimentalMaterial3Api::class)
@Composable
fun FavoriteEventsScreen(
    uiState: FavoriteEventsUiState,
    onIntent: (FavoriteEventsIntent) -> Unit,
) {

    LaunchedEffect(key1 = "FavoriteEvents") {
        onIntent(FavoriteEventsIntent.GetEvents)
    }

    Scaffold(topBar = {
        MediumTopAppBar(
            title = {
                Text(
                    text = stringResource(R.string.favorites),
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Black
                    )
                )
            },
        )
    }) {

        val localContext = LocalContext.current

        PullToRefreshBox(
            isRefreshing = uiState.isLoading,
            onRefresh = { onIntent(FavoriteEventsIntent.GetEvents) },
            modifier = Modifier
                .padding(top = it.calculateTopPadding()),
        ) {
            if (uiState.data.sections.isNotEmpty()) {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                ) {

                    for ((index, section) in uiState.data.sections.withIndex()) {

                        stickyHeader(
                            key = section.range?.first ?: "undated-$index",
                        ) {

                            Column(
                                modifier = Modifier
                                    .background(MaterialTheme.colorScheme.secondaryContainer)
                            ) {
                                HorizontalDivider()
                                Row(
                                    modifier = Modifier
                                        .padding(horizontal = 16.dp, vertical = 8.dp)
                                        .padding(top = if (index != 0) 0.dp else 0.dp)
                                        .fillMaxWidth()
                                ) {

                                    Text(
                                        text = if (section.isUndated || section.range == null) {
                                            stringResource(R.string.no_time_yet)
                                        } else {
                                            DateUtils.formatDateTime(
                                                localContext,
                                                section.range.first.time,
                                                DateUtils.FORMAT_SHOW_WEEKDAY
                                            )
                                        },
                                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                                        fontWeight = FontWeight.SemiBold,
                                    )
                                }
                                HorizontalDivider()
                            }

                        }

                        items(
                            items = section.events,
                            key = { event -> event.id },
                        ) { item ->
                            EventItem(event = item, onEventClick = { onIntent(FavoriteEventsIntent.EventClicked(item.id)) })
                        }



                    }

                }

            } else {
                Box(
                    modifier = Modifier
                        .verticalScroll(rememberScrollState())
                        .fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {

                    if (uiState.isLoading) {
                        CircularProgressIndicator()
                    } else {
                        if (uiState.isError != null) {
                            uiState.isError.localizedMessage?.let { it1 ->
                                Text(
                                    text = it1,
                                    modifier = Modifier.padding(16.dp),
                                )
                            }
                        } else {
                            Text(
                                text = stringResource(R.string.no_favorites),
                                modifier = Modifier.padding(16.dp),
                            )
                        }
                    }

                }
            }

        }


    }

}
