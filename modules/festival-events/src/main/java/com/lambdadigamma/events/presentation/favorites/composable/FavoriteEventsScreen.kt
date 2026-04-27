package com.lambdadigamma.events.presentation.favorites.composable

import android.text.format.DateUtils
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CalendarMonth
import androidx.compose.material.icons.rounded.FilterList
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsData
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsIntent
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsUiState
import com.lambdadigamma.events.presentation.favorites.FavoriteVenueFilterOption

@OptIn(ExperimentalFoundationApi::class, ExperimentalMaterial3Api::class)
@Composable
fun FavoriteEventsScreen(
    uiState: FavoriteEventsUiState,
    onIntent: (FavoriteEventsIntent) -> Unit,
    onShowTimetable: () -> Unit,
) {
    Scaffold(
        topBar = {
            MediumTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.favorites),
                        style = MaterialTheme.typography.headlineSmall.copy(
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Black,
                        ),
                    )
                },
                actions = {
                    if (uiState.data.filter.isEmpty) {
                        IconButton(onClick = { onIntent(FavoriteEventsIntent.ShowFilters) }) {
                            Icon(
                                imageVector = Icons.Rounded.FilterList,
                                contentDescription = stringResource(R.string.favorites_filter),
                            )
                        }
                    } else {
                        FilledTonalIconButton(onClick = { onIntent(FavoriteEventsIntent.ShowFilters) }) {
                            Icon(
                                imageVector = Icons.Rounded.FilterList,
                                contentDescription = stringResource(R.string.favorites_filter),
                            )
                        }
                    }
                },
            )
        },
    ) { paddingValues ->

        val localContext = LocalContext.current

        PullToRefreshBox(
            isRefreshing = uiState.isLoading,
            onRefresh = { onIntent(FavoriteEventsIntent.GetEvents) },
            modifier = Modifier.padding(top = paddingValues.calculateTopPadding()),
        ) {
            Column(modifier = Modifier.fillMaxSize()) {
                if (!uiState.data.filter.isEmpty) {
                    ActiveFavoriteFilterBar(
                        selectedVenueCount = uiState.data.filter.venueIds.size,
                        onClearFilter = { onIntent(FavoriteEventsIntent.ClearFilter) },
                    )
                }

                when {
                    uiState.data.sections.isNotEmpty() -> {
                        LazyColumn(
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f),
                        ) {
                            for ((index, section) in uiState.data.sections.withIndex()) {
                                stickyHeader(
                                    key = section.range?.first ?: "undated-$index",
                                ) {
                                    Column(
                                        modifier = Modifier
                                            .background(MaterialTheme.colorScheme.secondaryContainer),
                                    ) {
                                        HorizontalDivider()
                                        Row(
                                            modifier = Modifier
                                                .padding(horizontal = 16.dp, vertical = 8.dp)
                                                .fillMaxWidth(),
                                        ) {
                                            Text(
                                                text = if (section.isUndated || section.range == null) {
                                                    stringResource(R.string.no_time_yet)
                                                } else {
                                                    DateUtils.formatDateTime(
                                                        localContext,
                                                        section.range.first.time,
                                                        DateUtils.FORMAT_SHOW_WEEKDAY,
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
                                    EventItem(
                                        event = item,
                                        onEventClick = {
                                            onIntent(FavoriteEventsIntent.EventClicked(item.id))
                                        },
                                    )
                                }
                            }
                        }
                    }

                    else -> {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f)
                                .verticalScroll(rememberScrollState()),
                            contentAlignment = Alignment.Center,
                        ) {
                            when {
                                uiState.isLoading -> {
                                    CircularProgressIndicator()
                                }

                                uiState.isError != null -> {
                                    Text(
                                        text = uiState.isError.localizedMessage.orEmpty(),
                                        modifier = Modifier.padding(16.dp),
                                    )
                                }

                                uiState.data.hasAnyFavorites -> {
                                    EmptyFilteredFavoritesState(
                                        onClearFilter = { onIntent(FavoriteEventsIntent.ClearFilter) },
                                    )
                                }

                                else -> {
                                    EmptyFavoritesState(
                                        onShowTimetable = onShowTimetable,
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (uiState.data.isFilterSheetVisible) {
        ModalBottomSheet(
            onDismissRequest = { onIntent(FavoriteEventsIntent.HideFilters) },
        ) {
            FavoriteEventsFilterSheet(
                data = uiState.data,
                onToggleVenue = { venueId ->
                    onIntent(FavoriteEventsIntent.ToggleVenueFilter(venueId))
                },
                onClearFilter = { onIntent(FavoriteEventsIntent.ClearFilter) },
            )
        }
    }
}

@Composable
private fun ActiveFavoriteFilterBar(
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

            Column(
                modifier = Modifier.weight(1f),
            ) {
                Text(
                    text = stringResource(R.string.favorites_filter_active),
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                )
                Text(
                    text = stringResource(
                        R.string.favorites_filter_active_count,
                        selectedVenueCount,
                    ),
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
private fun EmptyFavoritesState(
    onShowTimetable: () -> Unit,
) {
    Column(
        modifier = Modifier.padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            imageVector = Icons.Rounded.CalendarMonth,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
            modifier = Modifier.size(36.dp),
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = stringResource(R.string.no_favorites),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = stringResource(R.string.no_favorites_hint),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(16.dp))
        FilledTonalButton(onClick = onShowTimetable) {
            Icon(
                imageVector = Icons.Rounded.CalendarMonth,
                contentDescription = null,
            )
            Text(
                text = stringResource(R.string.favorites_browse_timetable),
                modifier = Modifier.padding(start = 8.dp),
            )
        }
    }
}

@Composable
private fun EmptyFilteredFavoritesState(
    onClearFilter: () -> Unit,
) {
    Column(
        modifier = Modifier.padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            imageVector = Icons.Rounded.FilterList,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = stringResource(R.string.no_favorites_for_filter),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = stringResource(R.string.no_favorites_for_filter_hint),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(modifier = Modifier.height(16.dp))
        TextButton(onClick = onClearFilter) {
            Text(text = stringResource(R.string.favorites_clear_filter))
        }
    }
}

@Composable
private fun FavoriteEventsFilterSheet(
    data: FavoriteEventsData,
    onToggleVenue: (Long) -> Unit,
    onClearFilter: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(
                modifier = Modifier.weight(1f),
            ) {
                Text(
                    text = stringResource(R.string.favorites_filter_sheet_title),
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = stringResource(R.string.favorites_filter_sheet_subtitle),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            if (!data.filter.isEmpty) {
                TextButton(onClick = onClearFilter) {
                    Text(text = stringResource(R.string.favorites_clear_filter))
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        if (data.availableVenues.isEmpty()) {
            Text(
                text = stringResource(R.string.favorites_filter_no_venues),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(bottom = 32.dp),
            )
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 420.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(
                    items = data.availableVenues,
                    key = { venue -> venue.id },
                ) { venue ->
                    FavoriteVenueFilterRow(
                        venue = venue,
                        isSelected = venue.id in data.filter.venueIds,
                        onToggle = { onToggleVenue(venue.id) },
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))
    }
}

@Composable
private fun FavoriteVenueFilterRow(
    venue: FavoriteVenueFilterOption,
    isSelected: Boolean,
    onToggle: () -> Unit,
) {
    Surface(
        onClick = onToggle,
        shape = RoundedCornerShape(18.dp),
        color = if (isSelected) {
            MaterialTheme.colorScheme.secondaryContainer
        } else {
            MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.35f)
        },
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Checkbox(
                checked = isSelected,
                onCheckedChange = { onToggle() },
            )
            Spacer(modifier = Modifier.size(12.dp))
            Text(
                text = venue.name,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Medium,
            )
        }
    }
}
