package com.lambdadigamma.events.presentation.venue.composable

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.R as CoreR
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.detail.composable.PlaceInformation
import com.lambdadigamma.events.presentation.venue.VenueDetailUiState
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.presentation.PageBlockRenderer

@Composable
fun VenueDetailScreen(
    uiState: VenueDetailUiState,
    onBack: () -> Unit,
    onShowEvent: (Int) -> Unit,
) {
    Scaffold(
        topBar = {
            androidx.compose.material3.TopAppBar(
                title = {
                    Text(text = uiState.place?.name ?: stringResource(R.string.event_detail_venue_headline))
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Rounded.ArrowBack,
                            contentDescription = stringResource(CoreR.string.navigation_back),
                        )
                    }
                },
            )
        },
    ) { paddingValues ->
        when {
            uiState.isLoading && uiState.place == null && uiState.events.isEmpty() -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center,
                ) {
                    CircularProgressIndicator()
                }
            }

            uiState.place == null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(text = stringResource(R.string.venue_detail_not_found))
                }
            }

            else -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues)
                        .verticalScroll(rememberScrollState()),
                ) {
                    PlaceInformation(
                        place = requireNotNull(uiState.place),
                        modifier = Modifier.padding(16.dp),
                    )

                    if (uiState.blocks.isNotEmpty()) {
                        HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

                        val firstBlock = uiState.blocks.firstOrNull()?.data
                        if (firstBlock is TextBlock && firstBlock.isBlank()) {
                            VenueDetailEmptyInformation()
                        } else {
                            PageBlockRenderer(blocks = uiState.blocks)
                        }
                    }

                    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 16.dp, bottom = 32.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp),
                    ) {
                        Text(
                            text = stringResource(R.string.venue_detail_events),
                            style = MaterialTheme.typography.titleMedium,
                            modifier = Modifier.padding(horizontal = 16.dp),
                        )

                        if (uiState.events.isEmpty()) {
                            Text(
                                text = stringResource(R.string.venue_detail_no_events),
                                style = MaterialTheme.typography.bodyLarge.copy(
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    fontStyle = FontStyle.Italic,
                                ),
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                            )
                        } else {
                            uiState.events.forEach { event ->
                                EventItem(
                                    event = event,
                                    onEventClick = onShowEvent,
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun VenueDetailEmptyInformation() {
    Column(modifier = Modifier.padding(16.dp)) {
        BasicText(
            text = stringResource(R.string.no_additional_information),
            style = MaterialTheme.typography.bodyLarge.copy(
                fontStyle = FontStyle.Italic,
                fontWeight = FontWeight.Normal,
                color = MaterialTheme.colorScheme.onBackground,
            ),
        )
    }
}
