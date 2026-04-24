package com.lambdadigamma.events.presentation.composable

import android.content.res.Configuration
import android.text.format.DateUtils
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.core.ui.formattedShort
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import java.util.Date

@Composable
fun EventItem(
    event: EventDisplayable,
    onEventClick: (Int) -> Unit,
    showDivider: Boolean = true,
) {

    val context = LocalContext.current
    val configuration = LocalConfiguration.current
    val dateTba = stringResource(R.string.date_tba)
    val locationUnknown = stringResource(R.string.location_unknown)
    val startTime = event.startDate?.time
    val endTime = event.endDate?.time
    val placeName = event.place?.name

    val supportingText = remember(
        event.id,
        startTime,
        endTime,
        event.isOpenEnd,
        event.scheduleDisplayMode,
        placeName,
        configuration,
        dateTba,
        locationUnknown,
    ) {
        val timeDescription = if (!event.showsDateComponent) {
            null
        } else if (!event.showsTimeComponent) {
            if (startTime != null) {
                DateUtils.formatDateTime(
                    context,
                    startTime,
                    DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_ABBREV_MONTH or DateUtils.FORMAT_SHOW_WEEKDAY
                )
            } else {
                dateTba
            }
        } else if (event.isOpenEnd) {
            if (startTime != null) {
                DateUtils.formatDateTime(
                    context,
                    startTime,
                    DateUtils.FORMAT_SHOW_TIME
                )
            } else {
                dateTba
            }
        } else {
            event.dateRange?.formattedShort(context) ?: dateTba
        }

        val locationDescription = placeName ?: locationUnknown

        listOfNotNull(timeDescription, locationDescription).joinToString(" • ")
    }

    Column {
        ListItem(
            modifier = Modifier.clickable { onEventClick(event.id) },
            headlineContent = {
                BasicText(
                    text = event.name,
                    style = MaterialTheme.typography.bodyLarge
                        .copy(
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colorScheme.onBackground
                        ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            },
            supportingContent = {
                BasicText(
                    text = supportingText,
                    style = MaterialTheme.typography.bodyLarge
                        .copy(
                            color = MaterialTheme.colorScheme.onBackground
                        ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            },
            leadingContent = {
                Box(modifier = Modifier
                    .background(MaterialTheme.colorScheme.onBackground)
                    .width(2.dp)
                    .height(40.dp))
            },
            trailingContent = {
                if (event.isFavorite) {
                    Icon(
                        Icons.Filled.Favorite,
                        contentDescription = stringResource(R.string.is_favorite),
                        tint = Color.Red
                    )
                }
            },
        )
        if (showDivider) {
            HorizontalDivider(
                modifier = Modifier.padding(start = 32.dp),
                thickness = 1.dp,
                color = MaterialTheme.colorScheme.outlineVariant,
            )
        }
    }

}

@Composable
@Preview
private fun EventItemPreview() {
    EventItem(
        event = EventDisplayable(
            id = 1,
            name = "Editrix (US)",
            startDate = Date(1685112300000),
            endDate = Date(1685112300000 + 1000 * 60 * 30),
            isOpenEnd = true,
            place = PlaceDisplayable(
                id = 1,
                name = "Festivalgelände",
                point = Point(0.0, 0.0),
                addressLine1 = "Festivalgelände",
                addressLine2 = "47441 Moers",
            )
        ),
        onEventClick = {},
    )
}

@Composable
@Preview(uiMode = Configuration.UI_MODE_NIGHT_YES or Configuration.UI_MODE_TYPE_NORMAL,
    locale = "de"
)
private fun EventItemPreviewDark() {
    MoersFestivalTheme {
        EventItem(
            event = EventDisplayable(
                id = 1,
                name = "Editrix (US)",
                startDate = Date(1685112300000),
                endDate = Date(1685112300000 + 1000 * 60 * 30),
                place = PlaceDisplayable(
                    id = 1,
                    name = "Festivalgelände",
                    point = Point(0.0, 0.0),
                    addressLine1 = "Festivalgelände",
                    addressLine2 = "47441 Moers",
                ),
                isOpenEnd = false,
                isFavorite = true
            ),
            onEventClick = {},
        )
    }
}
