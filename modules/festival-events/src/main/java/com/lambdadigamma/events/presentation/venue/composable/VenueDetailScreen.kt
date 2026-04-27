package com.lambdadigamma.events.presentation.venue.composable

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.rounded.CalendarMonth
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.LocationOn
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.R as CoreR
import com.lambdadigamma.core.ui.ElevatedNavigationButton
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
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
            TopAppBar(
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
        VenueDetailContent(
            uiState = uiState,
            onShowEvent = onShowEvent,
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
        )
    }
}

@Composable
fun VenueDetailContent(
    uiState: VenueDetailUiState,
    onShowEvent: (Int) -> Unit,
    modifier: Modifier = Modifier,
    onDismiss: (() -> Unit)? = null,
    useSectionContainers: Boolean = true,
    topContent: (@Composable () -> Unit)? = null,
) {
    LazyColumn(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        topContent?.let { content ->
            item(key = "venue-top-content") {
                content()
            }
        }

        when {
            uiState.isLoading && uiState.place == null && uiState.events.isEmpty() -> {
                item(key = "venue-loading") {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(min = 180.dp)
                            .padding(24.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        CircularProgressIndicator()
                    }
                }
            }

            uiState.place == null -> {
                item(key = "venue-not-found") {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(min = 180.dp)
                            .padding(24.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(text = stringResource(R.string.venue_detail_not_found))
                    }
                }
            }

            else -> {
                val place = requireNotNull(uiState.place)

                item(key = "venue-info") {
                    VenueInfoPanel(
                        place = place,
                        onDismiss = onDismiss,
                        useContainer = useSectionContainers,
                        modifier = Modifier.padding(horizontal = 16.dp),
                    )
                }

                if (uiState.blocks.isNotEmpty()) {
                    item(key = "venue-blocks-divider") {
                        HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
                    }

                    item(key = "venue-blocks") {
                        val firstBlock = uiState.blocks.firstOrNull()?.data
                        if (firstBlock is TextBlock && firstBlock.isBlank()) {
                            VenueDetailEmptyInformation()
                        } else {
                            PageBlockRenderer(
                                blocks = uiState.blocks,
                                modifier = Modifier.padding(top = 10.dp, bottom = 10.dp),
                            )
                        }
                    }
                }

                item(key = "venue-events-divider") {
                    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
                }

                item(key = "venue-events-header") {
                    SectionHeader(
                        title = stringResource(R.string.venue_detail_events),
                        count = uiState.events.size.takeIf { it > 0 },
                        modifier = Modifier.padding(horizontal = 16.dp),
                    )
                }

                if (uiState.events.isEmpty()) {
                    item(key = "venue-events-empty") {
                        EmptyEventsPanel(
                            useContainer = useSectionContainers,
                            modifier = Modifier
                                .padding(horizontal = 16.dp)
                                .padding(bottom = 24.dp),
                        )
                    }
                } else {
                    item(key = "venue-events-list") {
                        EventListPanel(
                            events = uiState.events,
                            onShowEvent = onShowEvent,
                            useContainer = useSectionContainers,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp),
                        )
                    }

                    item(key = "venue-events-bottom-spacing") {
                        Box(modifier = Modifier.padding(bottom = 24.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun VenueInfoPanel(
    place: PlaceDisplayable,
    onDismiss: (() -> Unit)? = null,
    useContainer: Boolean = true,
    modifier: Modifier = Modifier,
) {
    val dismissAction = onDismiss
    val content: @Composable () -> Unit = {
        Column(
            modifier = if (useContainer) {
                Modifier.padding(16.dp)
            } else {
                Modifier.padding(vertical = 8.dp)
            },
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            InfoRow(
                icon = {
                    Icon(
                        imageVector = Icons.Rounded.LocationOn,
                        contentDescription = null,
                    )
                },
                content = {
                    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                        Text(
                            text = place.name,
                            style = MaterialTheme.typography.bodyLarge,
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colorScheme.onSurface,
                        )

                        listOf(place.addressLine1, place.addressLine2)
                            .map { it.trim() }
                            .filter { it.isNotBlank() }
                            .forEach { addressLine ->
                                Text(
                                    text = addressLine,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                    }
                },
                trailingContent = if (dismissAction == null) {
                    null
                } else {
                    {
                        IconButton(
                            onClick = dismissAction,
                            modifier = Modifier.size(40.dp),
                        ) {
                            Icon(
                                imageVector = Icons.Rounded.Close,
                                contentDescription = stringResource(R.string.venue_detail_close),
                                modifier = Modifier.size(20.dp),
                            )
                        }
                    }
                },
            )

            if (place.point.latitude != 0.0 && place.point.longitude != 0.0) {
                ElevatedNavigationButton(
                    point = place.point,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }

    if (useContainer) {
        Surface(
            modifier = modifier.fillMaxWidth(),
            shape = MaterialTheme.shapes.large,
            color = MaterialTheme.colorScheme.surfaceContainerLow,
        ) {
            content()
        }
    } else {
        Box(modifier = modifier.fillMaxWidth()) {
            content()
        }
    }
}

@Composable
private fun EventListPanel(
    events: List<EventDisplayable>,
    onShowEvent: (Int) -> Unit,
    useContainer: Boolean,
    modifier: Modifier = Modifier,
) {
    val content: @Composable () -> Unit = {
        Column {
            events.forEachIndexed { index, event ->
                EventItem(
                    event = event,
                    onEventClick = onShowEvent,
                    showDivider = index < events.lastIndex,
                    containerColor = Color.Transparent,
                )
            }
        }
    }

    if (useContainer) {
        Surface(
            modifier = modifier,
            shape = MaterialTheme.shapes.large,
            color = MaterialTheme.colorScheme.surfaceContainerLow,
        ) {
            content()
        }
    } else {
        Box(modifier = modifier) {
            content()
        }
    }
}

@Composable
private fun SectionHeader(
    title: String,
    count: Int?,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontWeight = FontWeight.SemiBold,
        )

        count?.let {
            Surface(
                shape = MaterialTheme.shapes.small,
                color = MaterialTheme.colorScheme.secondaryContainer,
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer,
            ) {
                Text(
                    text = it.toString(),
                    style = MaterialTheme.typography.labelMedium,
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                )
            }
        }
    }
}

@Composable
private fun EmptyEventsPanel(
    useContainer: Boolean = true,
    modifier: Modifier = Modifier,
) {
    val content: @Composable () -> Unit = {
        Row(
            modifier = if (useContainer) {
                Modifier.padding(16.dp)
            } else {
                Modifier.padding(vertical = 8.dp)
            },
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.Top,
        ) {
            Icon(
                imageVector = Icons.Rounded.CalendarMonth,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                text = stringResource(R.string.venue_detail_no_events),
                style = MaterialTheme.typography.bodyLarge.copy(
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontStyle = FontStyle.Italic,
                ),
            )
        }
    }

    if (!useContainer) {
        Box(modifier = modifier.fillMaxWidth()) {
            content()
        }
        return
    }

    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surfaceContainerLow,
    ) {
        content()
    }
}

@Composable
private fun VenueDetailEmptyInformation() {
    Column(modifier = Modifier.padding(16.dp)) {
        Text(
            text = stringResource(R.string.no_additional_information),
            style = MaterialTheme.typography.bodyLarge.copy(
                fontStyle = FontStyle.Italic,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            ),
        )
    }
}

@Composable
private fun InfoRow(
    icon: @Composable () -> Unit,
    content: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    trailingContent: (@Composable () -> Unit)? = null,
    iconShape: Shape = MaterialTheme.shapes.medium,
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.Top,
    ) {
        Surface(
            modifier = Modifier.size(32.dp),
            shape = iconShape,
            color = MaterialTheme.colorScheme.surfaceVariant,
            contentColor = MaterialTheme.colorScheme.onSurfaceVariant,
        ) {
            Box(contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier.size(20.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    icon()
                }
            }
        }

        Box(
            modifier = Modifier.weight(1f),
            contentAlignment = Alignment.TopStart,
        ) {
            content()
        }

        trailingContent?.invoke()
    }
}
