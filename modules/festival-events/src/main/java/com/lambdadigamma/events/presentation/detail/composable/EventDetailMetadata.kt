package com.lambdadigamma.events.presentation.detail.composable

import android.content.res.Configuration
import android.text.format.DateUtils
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.core.ui.formatted
import com.lambdadigamma.events.R
import com.lambdadigamma.events.data.local.model.ScheduleDisplayMode
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import java.util.Date

@Composable
fun EventDetailMetadata(
    title: String,
    place: PlaceDisplayable?,
    startDate: Date?,
    time: ClosedRange<Date>?,
    isOpenEnd: Boolean = false,
    scheduleDisplayMode: ScheduleDisplayMode = ScheduleDisplayMode.DATE_TIME,
    artists: List<String>,
    onShowVenue: (Long) -> Unit,
) {

    val locationDescription = place?.name ?: stringResource(R.string.location_unknown)

    val timeDescription = if (!scheduleDisplayMode.showsDateComponent) {
        null
    } else if (!scheduleDisplayMode.showsTimeComponent) {
        if (startDate != null) {
            DateUtils.formatDateTime(
                LocalContext.current,
                startDate.time,
                DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_ABBREV_MONTH or DateUtils.FORMAT_SHOW_WEEKDAY
            )
        } else {
            stringResource(R.string.date_tba)
        }
    } else if (isOpenEnd) {
        if (startDate != null) {
            DateUtils.formatDateTime(
                LocalContext.current,
                startDate.time,
                DateUtils.FORMAT_SHOW_TIME or DateUtils.FORMAT_SHOW_DATE
            )
        } else {
            stringResource(R.string.date_tba)
        }
    } else {
        time?.formatted(LocalContext.current) ?: stringResource(R.string.date_tba)
    }


    val artistsDescription = if (artists.any { it.isNotBlank() })
        artists.joinToString(", ")
    else stringResource(R.string.lineup_tba)

    Column(modifier = Modifier.padding(start = 16.dp, top = 24.dp, end = 16.dp, bottom = 24.dp)) {

        BasicText(
            text = title,
            style = MaterialTheme.typography.titleLarge
                .copy(fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onBackground)
        )

        Column(
            modifier = Modifier.padding(top = 12.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {

            if (place != null) {
                VenueMetadataLinkRow(
                    label = locationDescription,
                    onClick = { onShowVenue(place.id) },
                )
            } else {
                LabelWithIcon(label = locationDescription) {
                    Icon(painter = painterResource(id = R.drawable.location_on_20), contentDescription = null)
                }
            }

            if (timeDescription != null) {
                LabelWithIcon(label = timeDescription) {
                    Icon(painter = painterResource(id = R.drawable.schedule_20), contentDescription = null)
                }
            }

            LabelWithIcon(label = artistsDescription) {
                Icon(painter = painterResource(id = R.drawable.groups_20), contentDescription = null)
            }

        }

    }

}

@Composable
private fun VenueMetadataLinkRow(
    label: String,
    onClick: () -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 48.dp)
            .clip(MaterialTheme.shapes.medium)
            .clickable(onClick = onClick),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Icon(
            painter = painterResource(id = R.drawable.location_on_20),
            contentDescription = null,
        )

        BasicText(
            text = label,
            modifier = Modifier.weight(1f),
            style = MaterialTheme.typography.bodyLarge
                .copy(color = MaterialTheme.colorScheme.onBackground),
        )

        Icon(
            imageVector = Icons.AutoMirrored.Rounded.KeyboardArrowRight,
            contentDescription = null,
            modifier = Modifier.size(24.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun EventDetailMetadataPreviews_Light() {

    MoersFestivalTheme {

        EventDetailMetadata(
            title = "Matthias Schubert",
            place = PlaceDisplayable(
                id = 1,
                name = "moersify",
                point = Point(0.0, 0.0),
                addressLine1 = "",
                addressLine2 = "",
            ),
            startDate = Date(1622120400000L),
            time = Date(1622120400000L)..Date(1622127600000L),
            artists = listOf(""),
            scheduleDisplayMode = ScheduleDisplayMode.DATE,
            onShowVenue = {},
        )

    }

}

@Preview(
    showBackground = false, showSystemUi = false,
    uiMode = Configuration.UI_MODE_NIGHT_YES or Configuration.UI_MODE_TYPE_NORMAL
)
@Composable
private fun EventDetailMetadataPreviews_Dark() {

    MoersFestivalTheme(darkTheme = true) {

        EventDetailMetadata(
            title = "Matthias Schubert",
            place = PlaceDisplayable(
                id = 1,
                name = "moersify",
                point = Point(0.0, 0.0),
                addressLine1 = "",
                addressLine2 = "",
            ),
            startDate = Date(1622120400000L),
            time = Date(1622120400000L)..Date(1622127600000L),
            artists = listOf(""),
            isOpenEnd = true,
            onShowVenue = {},
        )

    }

}
