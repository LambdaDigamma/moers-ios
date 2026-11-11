package com.lambdadigamma.events.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.input.TextFieldState
import androidx.compose.foundation.text.input.clearText
import androidx.compose.foundation.text.input.rememberTextFieldState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.outlined.Videocam
import androidx.compose.material3.DockedSearchBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SearchBarDefaults
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.carousel.HorizontalMultiBrowseCarousel
import androidx.compose.material3.carousel.rememberCarouselState
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil3.compose.AsyncImage
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LargeTopBar
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.events.R
import com.lambdadigamma.events.models.Event
import com.lambdadigamma.events.models.EventDateFilter
import com.lambdadigamma.events.models.EventFilter
import com.lambdadigamma.events.models.EventSection
import com.lambdadigamma.events.models.EventSectionKind
import com.lambdadigamma.core.theme.MeinMoersTheme
import androidx.compose.ui.tooling.preview.Preview

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventOverviewScreen(onSelectEvent: (Int) -> Unit) {
    val viewModel: EventOverviewViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()
    val snackbarHostState = remember { SnackbarHostState() }
    val refreshFailedMessage = stringResource(R.string.events_refresh_failed)

    LaunchedEffect(uiState.refreshFailed, uiState.isEmpty) {
        if (uiState.refreshFailed && !uiState.isEmpty) {
            snackbarHostState.showSnackbar(refreshFailedMessage)
        }
    }

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeTopBar(
                title = stringResource(R.string.navigation_top_bar),
                scrollBehavior = scrollBehavior,
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) },
    ) { padding ->
        PullToRefreshBox(
            isRefreshing = uiState.isRefreshing && !uiState.isLoading,
            onRefresh = viewModel::refresh,
            modifier = Modifier
                .padding(padding)
                .fillMaxSize(),
        ) {
            when {
                uiState.isLoading -> LoadingContent()
                uiState.isEmpty && uiState.refreshFailed && !uiState.filter.isActive ->
                    ErrorContent(message = refreshFailedMessage, onRetry = viewModel::refresh)
                else -> EventList(
                    uiState = uiState,
                    onSelectEvent = onSelectEvent,
                    queryState = viewModel.query,
                    onSelectDateFilter = viewModel::selectDateFilter,
                    onToggleOnline = viewModel::toggleOnlineOnly,
                    onToggleFavorites = viewModel::toggleFavoritesOnly,
                    onResetFilters = viewModel::resetFilters,
                )
            }
        }
    }
}

@Composable
private fun EventList(
    uiState: EventOverviewUiState,
    onSelectEvent: (Int) -> Unit,
    queryState: TextFieldState,
    onSelectDateFilter: (EventDateFilter) -> Unit,
    onToggleOnline: () -> Unit,
    onToggleFavorites: () -> Unit,
    onResetFilters: () -> Unit,
) {
    val formatter = rememberEventFormatter()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 16.dp),
    ) {
        item(key = "search") {
            EventSearchField(state = queryState)
        }
        item(key = "filters") {
            EventFilterChips(
                filter = uiState.filter,
                onSelectDateFilter = onSelectDateFilter,
                onToggleOnline = onToggleOnline,
                onToggleFavorites = onToggleFavorites,
            )
        }
        if (uiState.spotlight.isNotEmpty()) {
            item(key = "spotlight") {
                SectionHeader(stringResource(R.string.events_section_spotlight))
                SpotlightCarousel(events = uiState.spotlight, onSelectEvent = onSelectEvent)
            }
        }
        uiState.sections.forEach { section ->
            item(key = "header-${section.kind}") {
                SectionHeader(stringResource(section.kind.titleRes()))
            }
            items(section.events, key = { it.id }) { event ->
                EventRow(
                    event = event,
                    isLive = event.id in uiState.liveEventIds,
                    isFavorite = event.id in uiState.favoriteIds,
                    formatter = formatter,
                    modifier = Modifier.clickable { onSelectEvent(event.id) },
                )
            }
        }
        if (uiState.isEmpty) {
            item(key = "empty") {
                EmptyEvents(isFiltered = uiState.filter.isActive, onResetFilters = onResetFilters)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EventSearchField(state: TextFieldState) {
    val focusManager = LocalFocusManager.current
    DockedSearchBar(
        inputField = {
            SearchBarDefaults.InputField(
                state = state,
                onSearch = { focusManager.clearFocus() },
                expanded = false,
                onExpandedChange = {},
                placeholder = { Text(stringResource(R.string.events_search_placeholder)) },
                leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
                trailingIcon = if (state.text.isNotEmpty()) {
                    {
                        IconButton(onClick = { state.clearText() }) {
                            Icon(Icons.Filled.Close, contentDescription = stringResource(R.string.events_search_clear))
                        }
                    }
                } else {
                    null
                },
            )
        },
        expanded = false,
        onExpandedChange = {},
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
    ) {}
}

@Composable
private fun EventFilterChips(
    filter: EventFilter,
    onSelectDateFilter: (EventDateFilter) -> Unit,
    onToggleOnline: () -> Unit,
    onToggleFavorites: () -> Unit,
) {
    val dateFilters = listOf(
        EventDateFilter.TODAY to R.string.events_filter_today,
        EventDateFilter.TOMORROW to R.string.events_filter_tomorrow,
        EventDateFilter.WEEKEND to R.string.events_filter_weekend,
        EventDateFilter.NEXT_7_DAYS to R.string.events_filter_next_7_days,
    )
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        item(key = "favorites") {
            FilterChip(
                selected = filter.favoritesOnly,
                onClick = onToggleFavorites,
                label = { Text(stringResource(R.string.events_filter_favorites)) },
                leadingIcon = {
                    Icon(
                        if (filter.favoritesOnly) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                        contentDescription = null,
                    )
                },
            )
        }
        items(dateFilters, key = { it.first }) { (dateFilter, label) ->
            FilterChip(
                selected = filter.date == dateFilter,
                onClick = { onSelectDateFilter(dateFilter) },
                label = { Text(stringResource(label)) },
            )
        }
        item(key = "online") {
            FilterChip(
                selected = filter.onlineOnly,
                onClick = onToggleOnline,
                label = { Text(stringResource(R.string.events_filter_online)) },
                leadingIcon = { Icon(Icons.Outlined.Videocam, contentDescription = null) },
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SpotlightCarousel(events: List<Event>, onSelectEvent: (Int) -> Unit) {
    val formatter = rememberEventFormatter()
    HorizontalMultiBrowseCarousel(
        state = rememberCarouselState { events.size },
        preferredItemWidth = 280.dp,
        itemSpacing = 8.dp,
        contentPadding = PaddingValues(horizontal = 16.dp),
        modifier = Modifier
            .fillMaxWidth()
            .height(220.dp),
    ) { index ->
        val event = events[index]
        Box(
            modifier = Modifier
                .fillMaxSize()
                .maskClip(MaterialTheme.shapes.extraLarge)
                .background(MaterialTheme.colorScheme.surfaceContainerHighest)
                .clickable { onSelectEvent(event.id) },
            contentAlignment = Alignment.BottomStart,
        ) {
            AsyncImage(
                model = event.imageUrl,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize(),
            )
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Brush.verticalGradient(0.4f to Color.Transparent, 1f to Color.Black.copy(alpha = 0.7f)))
            )
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = event.name,
                    style = MaterialTheme.typography.titleMedium,
                    color = Color.White,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                Text(
                    text = formatter.shortDate(event),
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.White.copy(alpha = 0.85f),
                    maxLines = 1,
                )
            }
        }
    }
}

@Composable
private fun SectionHeader(text: String) {
    Text(
        text = text,
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.primary,
        modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 20.dp, bottom = 8.dp),
    )
}

@Composable
private fun EmptyEvents(isFiltered: Boolean, onResetFilters: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Text(
            text = stringResource(R.string.events_empty),
            style = MaterialTheme.typography.titleMedium,
            textAlign = TextAlign.Center,
        )
        if (isFiltered) {
            Text(
                text = stringResource(R.string.events_empty_filtered),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
            TextButton(onClick = onResetFilters) {
                Text(stringResource(R.string.events_reset_filters))
            }
        }
    }
}

private fun EventSectionKind.titleRes(): Int = when (this) {
    EventSectionKind.TODAY -> R.string.events_section_today
    EventSectionKind.TOMORROW -> R.string.events_section_tomorrow
    EventSectionKind.UPCOMING -> R.string.events_section_upcoming
    EventSectionKind.LATER -> R.string.events_section_later
}

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun EventListPreview() {
    val start = 1_794_000_000_000L
    val hour = 60 * 60 * 1000L
    val events = listOf(
        Event(1, "Offene PC-Sprechstunde", start, start + 2 * hour, category = "Information und Weiterbildung", locationName = "vhs Moers"),
        Event(2, "Stadtführung durch die Altstadt", start + 4 * hour, null, category = "Stadtführungen", locationName = "Altmarkt"),
        Event(3, "Lesung: Krimis vom Niederrhein", start + 26 * hour, start + 28 * hour, category = "Lesung", locationName = "Bibliothek Moers"),
        Event(4, "Online-Vortrag: Synthetische Biologie", start + 72 * hour, null, category = "Vortrag", isOnline = true),
    )
    MeinMoersTheme {
        EventList(
            uiState = EventOverviewUiState(
                filter = EventFilter(date = EventDateFilter.TODAY),
                sections = listOf(
                    EventSection(EventSectionKind.TODAY, events.take(2)),
                    EventSection(EventSectionKind.TOMORROW, listOf(events[2])),
                    EventSection(EventSectionKind.UPCOMING, listOf(events[3])),
                ),
                liveEventIds = setOf(1),
                favoriteIds = setOf(3),
                isLoading = false,
            ),
            onSelectEvent = {},
            queryState = rememberTextFieldState(),
            onSelectDateFilter = {},
            onToggleOnline = {},
            onToggleFavorites = {},
            onResetFilters = {},
        )
    }
}
