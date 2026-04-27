package com.lambdadigamma.events.presentation.timetable.composable

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.FilterList
import androidx.compose.material3.Checkbox
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.filter.EventVenueFilterOption
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableData
import com.lambdadigamma.events.presentation.timetable.TimetableUiState

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun TimetableScreen(
    uiState: TimetableUiState,
    onIntent: (TimetableIntent) -> Unit,
    onShowDownload: () -> Unit = {},
    pagerState: PagerState,
    currentIndex: MutableState<Int>
) {

    LaunchedEffect(key1 = "refreshTimetable", block = {
//        onIntent(TimetableIntent.GetEvents)
    })

    Scaffold(
        topBar = {
            MediumTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.timetable),
                        style = MaterialTheme.typography.headlineSmall.copy(
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Black
                        )
                    )
                },
                actions = {
                    if (uiState.data.filter.isEmpty) {
                        IconButton(onClick = { onIntent(TimetableIntent.ShowFilters) }) {
                            Icon(
                                imageVector = Icons.Rounded.FilterList,
                                contentDescription = stringResource(R.string.timetable_filter),
                            )
                        }
                    } else {
                        FilledTonalIconButton(onClick = { onIntent(TimetableIntent.ShowFilters) }) {
                            Icon(
                                imageVector = Icons.Rounded.FilterList,
                                contentDescription = stringResource(R.string.timetable_filter),
                            )
                        }
                    }
                    IconButton(onClick = onShowDownload) {
                        Icon(
                            painter = painterResource(id = R.drawable.baseline_download_24),
                            contentDescription = stringResource(R.string.download_timetable)
                        )
                    }
                }
            )
        },
//        snackbarHost = { SnackbarHost(snackbarHostState) },
    ) { it ->

        TimetableContent(
            modifier = Modifier.padding(top = it.calculateTopPadding()),
            uiState = uiState,
            onIntent = onIntent,
            pagerState = pagerState,
            currentIndex = currentIndex
        )

    }

    if (uiState.data.isFilterSheetVisible) {
        ModalBottomSheet(
            onDismissRequest = { onIntent(TimetableIntent.HideFilters) },
        ) {
            TimetableFilterSheet(
                data = uiState.data,
                onToggleFavorites = { onIntent(TimetableIntent.ToggleFavoriteFilter) },
                onToggleVenue = { venueId -> onIntent(TimetableIntent.ToggleVenueFilter(venueId)) },
                onSelectAllVenues = { onIntent(TimetableIntent.SelectAllVenues) },
                onDeselectAllVenues = { onIntent(TimetableIntent.DeselectAllVenues) },
                onClearFilter = { onIntent(TimetableIntent.ClearFilter) },
                onDone = { onIntent(TimetableIntent.HideFilters) },
            )
        }
    }
    
}

@Composable
private fun TimetableFilterSheet(
    data: TimetableData,
    onToggleFavorites: () -> Unit,
    onToggleVenue: (Long) -> Unit,
    onSelectAllVenues: () -> Unit,
    onDeselectAllVenues: () -> Unit,
    onClearFilter: () -> Unit,
    onDone: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .navigationBarsPadding(),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 24.dp, end = 12.dp, bottom = 12.dp),
            verticalAlignment = Alignment.Top,
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = stringResource(R.string.timetable_filter_sheet_title),
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = stringResource(R.string.timetable_filter_sheet_subtitle),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            TextButton(onClick = onDone) {
                Text(text = stringResource(R.string.timetable_filter_done))
            }
        }

        if (!data.filter.isEmpty) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 12.dp),
            ) {
                Spacer(modifier = Modifier.weight(1f))
                TextButton(onClick = onClearFilter) {
                    Text(text = stringResource(R.string.favorites_clear_filter))
                }
            }
        }

        TimetableFilterDivider()

        ListItem(
            headlineContent = {
                Text(
                    text = stringResource(R.string.timetable_filter_only_favorites),
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium,
                )
            },
            trailingContent = {
                Switch(
                    checked = data.filter.showOnlyFavorites,
                    onCheckedChange = { onToggleFavorites() },
                )
            },
            modifier = Modifier
                .fillMaxWidth()
                .clickable(onClick = onToggleFavorites),
            colors = ListItemDefaults.colors(containerColor = Color.Transparent),
        )

        TimetableFilterDivider(modifier = Modifier.padding(horizontal = 24.dp))

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 24.dp, end = 8.dp, top = 16.dp, bottom = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = stringResource(R.string.timetable_filter_venues),
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.weight(1f),
            )

            if (data.availableVenues.isNotEmpty()) {
                TextButton(onClick = onSelectAllVenues) {
                    Text(text = stringResource(R.string.timetable_filter_select_all))
                }
                TextButton(onClick = onDeselectAllVenues) {
                    Text(text = stringResource(R.string.timetable_filter_deselect_all))
                }
            }
        }

        if (data.availableVenues.isEmpty()) {
            Text(
                text = stringResource(R.string.timetable_filter_no_venues),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 24.dp, end = 24.dp, bottom = 32.dp),
            )
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 420.dp),
                contentPadding = PaddingValues(bottom = 8.dp),
            ) {
                items(
                    items = data.availableVenues,
                    key = EventVenueFilterOption::id,
                ) { venue ->
                    TimetableVenueFilterRow(
                        venue = venue,
                        isSelected = venue.id in data.filter.venueIds,
                        onToggle = { onToggleVenue(venue.id) },
                    )
                }
            }
        }
    }
}

@Composable
private fun TimetableVenueFilterRow(
    venue: EventVenueFilterOption,
    isSelected: Boolean,
    onToggle: () -> Unit,
) {
    Column {
        ListItem(
            leadingContent = {
                Checkbox(
                    checked = isSelected,
                    onCheckedChange = { onToggle() },
                )
            },
            headlineContent = {
                Text(
                    text = venue.name,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                )
            },
            modifier = Modifier
                .fillMaxWidth()
                .clickable(onClick = onToggle),
            colors = ListItemDefaults.colors(
                containerColor = if (isSelected) {
                    MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.35f)
                } else {
                    Color.Transparent
                },
            ),
        )

        TimetableFilterDivider(modifier = Modifier.padding(start = 72.dp))
    }
}

@Composable
private fun TimetableFilterDivider(
    modifier: Modifier = Modifier,
) {
    HorizontalDivider(
        modifier = modifier,
        thickness = Dp.Hairline,
        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.45f),
    )
}

@OptIn(ExperimentalFoundationApi::class)
@Preview
@Composable
private fun TimetableScreenPreview() {
    MoersFestivalTheme() {
        TimetableScreen(
            uiState = TimetableUiState(),
            onIntent = {},
            pagerState = rememberPagerState(
                initialPage = 0,
                initialPageOffsetFraction = 0f,
                pageCount = { 10 }
            ),
            currentIndex = mutableStateOf(0)
        )
    }
}
