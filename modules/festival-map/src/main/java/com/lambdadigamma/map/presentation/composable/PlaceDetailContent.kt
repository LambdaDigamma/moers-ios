package com.lambdadigamma.map.presentation.composable

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import com.lambdadigamma.events.presentation.detail.composable.PlaceInformation
import com.lambdadigamma.map.R
import com.lambdadigamma.map.data.model.FestivalMapPlace

@Composable
internal fun PlaceDetailContent(
    place: FestivalMapPlace,
    events: List<EventDisplayable>,
    isLoadingEvents: Boolean,
    onDismiss: () -> Unit,
    onShowEvent: (Int) -> Unit,
    minContentHeight: Dp,
    modifier: Modifier = Modifier,
) {
    LazyColumn(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 12.dp, vertical = 4.dp),
    ) {
        item(key = "place-info") {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
            ) {
                PlaceInformation(
                    place = PlaceDisplayable(
                        id = place.id,
                        name = place.name,
                        point = Point(
                            latitude = place.point.latitude,
                            longitude = place.point.longitude,
                        ),
                        addressLine1 = place.addressLine1,
                        addressLine2 = place.addressLine2,
                    ),
                    modifier = Modifier
                        .weight(1f)
                        .padding(start = 4.dp),
                )

                IconButton(
                    onClick = onDismiss,
                    modifier = Modifier.size(36.dp),
                ) {
                    Icon(
                        imageVector = Icons.Rounded.Close,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
                    )
                }
            }
        }

        item(key = "divider") {
            HorizontalDivider(
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.padding(vertical = 8.dp),
            )
        }

        item(key = "events-header") {
            Text(
                text = stringResource(R.string.map_place_events),
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(start = 4.dp, bottom = 4.dp),
            )
        }

        when {
            isLoadingEvents -> {
                item(key = "events-loading") {
                    CircularProgressIndicator(
                        modifier = Modifier
                            .padding(vertical = 16.dp)
                            .size(24.dp),
                        strokeWidth = 2.dp,
                    )
                }
            }

            events.isEmpty() -> {
                item(key = "events-empty") {
                    Text(
                        text = stringResource(R.string.map_place_no_events),
                        style = MaterialTheme.typography.bodyLarge.copy(
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            fontStyle = FontStyle.Italic,
                        ),
                        modifier = Modifier.padding(start = 4.dp, top = 8.dp, bottom = 16.dp),
                    )
                }
            }

            else -> {
                items(
                    items = events,
                    key = { "event-${it.id}" },
                ) { event ->
                    EventItem(
                        event = event,
                        onEventClick = onShowEvent,
                    )
                }
            }
        }
    }
}
