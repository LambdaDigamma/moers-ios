package com.lambdadigamma.events.presentation.search

import android.text.format.DateUtils
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.Search
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.composable.EventItem

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventSearchScreen(
    uiState: EventSearchUiState,
    onIntent: (EventSearchIntent) -> Unit,
    onBack: () -> Unit,
) {
    Scaffold(
        topBar = {
            MediumTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.event_search_title),
                        style = MaterialTheme.typography.headlineSmall.copy(
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Black,
                        ),
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = stringResource(R.string.event_search_back),
                        )
                    }
                },
            )
        },
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(top = paddingValues.calculateTopPadding())
                .navigationBarsPadding(),
        ) {
            EventSearchField(
                query = uiState.query,
                onQueryChange = { query -> onIntent(EventSearchQueryChanged(query)) },
                onClear = { onIntent(EventSearchQueryChanged("")) },
            )

            when {
                uiState.isLoading && uiState.sections.isEmpty() -> {
                    EventSearchLoadingState()
                }

                uiState.isError != null && uiState.sections.isEmpty() -> {
                    EventSearchErrorState(
                        throwable = uiState.isError,
                        onRetry = { onIntent(EventSearchLoadEvents) },
                    )
                }

                uiState.sections.isEmpty() -> {
                    EventSearchEmptyState(
                        hasQuery = uiState.query.isNotBlank(),
                    )
                }

                else -> {
                    EventSearchResults(
                        sections = uiState.sections,
                        onEventClick = { eventId -> onIntent(EventSearchEventClicked(eventId)) },
                    )
                }
            }
        }
    }
}

@Composable
private fun EventSearchField(
    query: String,
    onQueryChange: (String) -> Unit,
    onClear: () -> Unit,
) {
    val focusRequester = remember { FocusRequester() }

    LaunchedEffect(Unit) {
        focusRequester.requestFocus()
    }

    TextField(
        value = query,
        onValueChange = onQueryChange,
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .height(56.dp)
            .focusRequester(focusRequester),
        leadingIcon = {
            Icon(
                imageVector = Icons.Rounded.Search,
                contentDescription = null,
            )
        },
        trailingIcon = {
            if (query.isNotBlank()) {
                IconButton(onClick = onClear) {
                    Icon(
                        imageVector = Icons.Rounded.Close,
                        contentDescription = stringResource(R.string.event_search_clear),
                    )
                }
            }
        },
        placeholder = {
            Text(text = stringResource(R.string.event_search_placeholder))
        },
        singleLine = true,
        shape = MaterialTheme.shapes.large,
        colors = TextFieldDefaults.colors(
            focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.55f),
            unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
            disabledContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
            focusedIndicatorColor = Color.Transparent,
            unfocusedIndicatorColor = Color.Transparent,
            disabledIndicatorColor = Color.Transparent,
        ),
    )
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun EventSearchResults(
    sections: List<EventSearchSection>,
    onEventClick: (Int) -> Unit,
) {
    val localContext = LocalContext.current

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 16.dp),
    ) {
        sections.forEachIndexed { sectionIndex, section ->
            stickyHeader(
                key = section.range?.first?.time ?: "undated-$sectionIndex",
            ) {
                EventSearchDayHeader(
                    title = if (section.isUndated || section.range == null) {
                        stringResource(R.string.no_time_yet)
                    } else {
                        DateUtils.formatDateTime(
                            localContext,
                            section.range.first.time,
                            DateUtils.FORMAT_SHOW_WEEKDAY,
                        )
                    },
                )
            }

            itemsIndexed(
                items = section.events,
                key = { _, event -> event.id },
            ) { index, event ->
                EventItem(
                    event = event,
                    onEventClick = onEventClick,
                    showDivider = index < section.events.lastIndex,
                )
            }
        }
    }
}

@Composable
private fun EventSearchDayHeader(
    title: String,
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
                text = title,
                color = MaterialTheme.colorScheme.onSecondaryContainer,
                fontWeight = FontWeight.SemiBold,
            )
        }
        HorizontalDivider()
    }
}

@Composable
private fun EventSearchLoadingState() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        CircularProgressIndicator()
    }
}

@Composable
private fun EventSearchErrorState(
    throwable: Throwable,
    onRetry: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text(
            text = throwable.localizedMessage ?: throwable.message ?: stringResource(R.string.event_search_error),
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = onRetry) {
            Text(text = stringResource(R.string.event_search_retry))
        }
    }
}

@Composable
private fun EventSearchEmptyState(
    hasQuery: Boolean,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            imageVector = Icons.Rounded.Search,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
            modifier = Modifier.size(36.dp),
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = stringResource(
                if (hasQuery) {
                    R.string.event_search_no_results
                } else {
                    R.string.event_search_no_events
                },
            ),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = stringResource(
                if (hasQuery) {
                    R.string.event_search_no_results_hint
                } else {
                    R.string.event_search_no_events_hint
                },
            ),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
    }
}

@Preview
@Composable
private fun EventSearchScreenPreview() {
    MoersFestivalTheme {
        EventSearchScreen(
            uiState = EventSearchUiState(),
            onIntent = {},
            onBack = {},
        )
    }
}
