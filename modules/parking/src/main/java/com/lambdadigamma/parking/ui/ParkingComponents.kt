package com.lambdadigamma.parking.ui

import android.text.format.DateUtils
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import com.lambdadigamma.parking.R
import java.util.Date

/** Warning shown when the parking guidance system has not sent new data for more than a day. */
@Composable
fun ParkingOutdatedWarning(lastUpdate: Date?, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val date = lastUpdate?.let {
        DateUtils.formatDateTime(context, it.time, DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_SHOW_TIME)
    } ?: "–"
    ListItem(
        headlineContent = { Text(stringResource(R.string.parking_outdated, date)) },
        leadingContent = { Icon(Icons.Outlined.Info, contentDescription = null) },
        colors = ListItemDefaults.colors(
            containerColor = MaterialTheme.colorScheme.errorContainer,
            headlineColor = MaterialTheme.colorScheme.onErrorContainer,
            leadingIconColor = MaterialTheme.colorScheme.onErrorContainer,
        ),
        modifier = modifier.fillMaxWidth(),
    )
}

@Composable
fun relativeUpdateText(date: Date?): String? {
    date ?: return null
    val relative = DateUtils.getRelativeTimeSpanString(
        date.time,
        System.currentTimeMillis(),
        DateUtils.MINUTE_IN_MILLIS,
    ).toString()
    return stringResource(R.string.parking_updated, relative)
}

@Composable
fun ParkingDisclaimer(modifier: Modifier = Modifier) {
    Text(
        text = stringResource(R.string.parking_areas_resource_disclaimer) + "\n" +
            stringResource(R.string.parking_areas_resource_source),
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        style = MaterialTheme.typography.labelMedium,
        modifier = modifier.padding(),
    )
}
