package com.lambdadigamma.events.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.Videocam
import androidx.compose.material3.Badge
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.events.R
import com.lambdadigamma.events.models.Event

@Composable
fun EventRow(
    event: Event,
    isLive: Boolean,
    formatter: EventFormatter,
    modifier: Modifier = Modifier,
    isFavorite: Boolean = false,
) {
    ListItem(
        modifier = modifier,
        leadingContent = { DateBadge(event = event, formatter = formatter) },
        overlineContent = event.category?.let { category ->
            { Text(category, maxLines = 1, overflow = TextOverflow.Ellipsis) }
        },
        headlineContent = {
            Text(
                text = event.name,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                textDecoration = if (event.isCancelled) TextDecoration.LineThrough else null,
            )
        },
        supportingContent = {
            Text(
                text = listOfNotNull(formatter.shortDate(event), event.locationName)
                    .filter { it.isNotBlank() }
                    .joinToString(" · "),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
        },
        trailingContent = when {
            event.isCancelled -> {
                {
                    Badge(containerColor = MaterialTheme.colorScheme.errorContainer) {
                        Text(stringResource(R.string.event_cancelled))
                    }
                }
            }
            isLive -> {
                {
                    Badge(containerColor = MaterialTheme.colorScheme.primary) {
                        Text(stringResource(R.string.event_live))
                    }
                }
            }
            event.isOnline -> {
                {
                    Icon(
                        imageVector = Icons.Outlined.Videocam,
                        contentDescription = stringResource(R.string.event_online),
                    )
                }
            }
            isFavorite -> {
                {
                    Icon(
                        imageVector = Icons.Filled.Favorite,
                        contentDescription = stringResource(R.string.events_filter_favorites),
                        tint = MaterialTheme.colorScheme.primary,
                    )
                }
            }
            else -> null
        },
    )
}

@Composable
private fun DateBadge(event: Event, formatter: EventFormatter) {
    Surface(
        color = MaterialTheme.colorScheme.secondaryContainer,
        contentColor = MaterialTheme.colorScheme.onSecondaryContainer,
        shape = MaterialTheme.shapes.medium,
        modifier = Modifier.width(52.dp),
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.size(width = 52.dp, height = 56.dp),
        ) {
            Text(formatter.weekday(event), style = MaterialTheme.typography.labelSmall)
            Text(formatter.dayOfMonth(event), style = MaterialTheme.typography.titleLarge)
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun EventRowPreview() {
    MeinMoersTheme {
        val start = 1_794_000_000_000L
        Column {
            EventRow(
                event = Event(
                    id = 1,
                    name = "Offene PC-Sprechstunde",
                    startDate = start,
                    endDate = start + 90 * 60 * 1000,
                    category = "Information und Weiterbildung",
                    locationName = "vhs Moers",
                ),
                isLive = true,
                formatter = rememberEventFormatter(),
            )
            EventRow(
                event = Event(id = 2, name = "Stadtführung", startDate = start, endDate = null, isCancelled = true),
                isLive = false,
                formatter = rememberEventFormatter(),
            )
        }
    }
}
