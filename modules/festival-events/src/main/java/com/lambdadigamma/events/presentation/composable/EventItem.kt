package com.lambdadigamma.events.presentation.composable

import android.content.res.Configuration
import android.text.format.DateUtils
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.Divider
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.core.ui.formatted
import com.lambdadigamma.core.ui.formattedShort
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Date
import java.util.Formatter
import java.util.Locale
import java.util.TimeZone

@Composable
fun EventItem(event: EventDisplayable, onEventClick: (Int) -> Unit) {

    val timeDescription = if (event.isOpenEnd) {
        if (event.startDate != null) {
            DateUtils.formatDateTime(
                LocalContext.current,
                event.startDate.time,
                DateUtils.FORMAT_SHOW_TIME
            )
        } else {
            stringResource(R.string.date_tba)
        }
    } else {
        event.dateRange?.formattedShort(LocalContext.current) ?: stringResource(R.string.date_tba)
    }

    val locationDescription = if (event.place != null) {
        event.place.name
    } else {
        stringResource(R.string.location_unknown)
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
                    text = "$timeDescription • $locationDescription",
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
        HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
    }

    Date().time

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