package com.lambdadigamma.events.presentation.detail.composable

import android.content.res.Configuration
import android.text.format.DateUtils
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.core.ui.formatted
import com.lambdadigamma.events.data.local.model.ScheduleDisplayMode
import com.lambdadigamma.events.R
import java.util.Date

@Composable
fun EventDetailMetadata(
    title: String,
    location: String?,
    startDate: Date?,
    time: ClosedRange<Date>?,
    isOpenEnd: Boolean = false,
    scheduleDisplayMode: ScheduleDisplayMode = ScheduleDisplayMode.DATE_TIME,
    artists: List<String>
) {

    val locationDescription = location ?: stringResource(R.string.location_unknown)

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

    Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)) {

        BasicText(
            text = title,
            style = MaterialTheme.typography.titleLarge
                .copy(fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onBackground)
        )

        Column(modifier = Modifier.padding(top = 8.dp, bottom = 8.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {

            LabelWithIcon(label = locationDescription, icon = {
                Icon(painter = painterResource(id = R.drawable.location_on_20), contentDescription = null)
            })

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

@Preview(showBackground = true)
@Composable
private fun EventDetailMetadataPreviews_Light() {

    MoersFestivalTheme {

        EventDetailMetadata(
            title = "Matthias Schubert",
            location = "moersify",
            startDate = Date(1622120400000L),
            time = Date(1622120400000L)..Date(1622127600000L),
            artists = listOf(""),
            scheduleDisplayMode = ScheduleDisplayMode.DATE,
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
            location = "moersify",
            startDate = Date(1622120400000L),
            time = Date(1622120400000L)..Date(1622127600000L),
            artists = listOf(""),
            isOpenEnd = true
        )

    }

}
