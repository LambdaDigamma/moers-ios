package com.lambdadigamma.events.ui

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.CalendarContract
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.OpenInNew
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.Call
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.CalendarMonth
import androidx.compose.material.icons.outlined.Email
import androidx.compose.material.icons.outlined.EventBusy
import androidx.compose.material.icons.outlined.Groups
import androidx.compose.material.icons.outlined.Place
import androidx.compose.material.icons.outlined.Schedule
import androidx.compose.material.icons.outlined.Share
import androidx.compose.material.icons.outlined.Videocam
import androidx.compose.material3.AssistChip
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil3.compose.AsyncImage
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.events.R
import com.lambdadigamma.events.models.Event

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventDetailScreen(id: Int, onBack: () -> Unit) {
    val viewModel: EventDetailViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val isFavorite by viewModel.isFavorite.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val scrollBehavior = TopAppBarDefaults.pinnedScrollBehavior()

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            TopAppBar(
                title = {},
                navigationIcon = { NavigationBackButton(onBack = onBack) },
                actions = {
                    val event = (uiState as? EventDetailUiState.Loaded)?.event
                    if (event != null) {
                        IconButton(onClick = viewModel::toggleFavorite) {
                            Icon(
                                imageVector = if (isFavorite) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                                contentDescription = stringResource(
                                    if (isFavorite) R.string.event_favorite_remove else R.string.event_favorite_add
                                ),
                            )
                        }
                    }
                    event?.url?.let { url ->
                        IconButton(onClick = { context.shareEvent(event.name, url) }) {
                            Icon(Icons.Outlined.Share, contentDescription = stringResource(R.string.event_detail_share))
                        }
                    }
                },
                scrollBehavior = scrollBehavior,
            )
        },
    ) { padding ->
        val modifier = Modifier
            .padding(padding)
            .fillMaxSize()
        when (val state = uiState) {
            EventDetailUiState.Loading -> LoadingContent(modifier)
            EventDetailUiState.NotFound -> ErrorContent(
                message = stringResource(R.string.event_detail_not_found),
                modifier = modifier,
            )
            EventDetailUiState.Failed -> ErrorContent(message = null, modifier = modifier, onRetry = viewModel::refresh)
            is EventDetailUiState.Loaded -> EventDetailContent(event = state.event, modifier = modifier)
        }
    }
}

@Composable
fun EventDetailContent(event: Event, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val formatter = rememberEventFormatter()

    Column(modifier = modifier.verticalScroll(rememberScrollState())) {
        event.imageUrl?.let { imageUrl ->
            AsyncImage(
                model = imageUrl,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .padding(horizontal = 16.dp)
                    .fillMaxWidth()
                    .aspectRatio(16f / 9f)
                    .clip(MaterialTheme.shapes.extraLarge),
            )
        }

        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            event.category?.let { category ->
                Text(
                    text = category,
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.primary,
                )
            }
            Text(text = event.name, style = MaterialTheme.typography.headlineSmall)
            event.subtitle?.let { subtitle ->
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        if (event.isCancelled) {
            ListItem(
                headlineContent = { Text(stringResource(R.string.event_cancelled)) },
                leadingContent = {
                    Icon(Icons.Outlined.EventBusy, contentDescription = null, tint = MaterialTheme.colorScheme.error)
                },
            )
        }

        ListItem(
            headlineContent = { Text(formatter.longDate(event)) },
            leadingContent = { Icon(Icons.Outlined.Schedule, contentDescription = null) },
        )

        if (event.locationName != null || event.addressLines.isNotEmpty()) {
            ListItem(
                headlineContent = { Text(event.locationName ?: event.addressLines.first()) },
                supportingContent = event.addressLines
                    .filter { line -> event.locationName?.contains(line) != true }
                    .takeIf { it.isNotEmpty() }
                    ?.let { lines -> { Text(lines.joinToString("\n")) } },
                leadingContent = { Icon(Icons.Outlined.Place, contentDescription = null) },
                trailingContent = if (event.hasCoordinates || event.addressLines.isNotEmpty()) {
                    { Icon(Icons.AutoMirrored.Outlined.OpenInNew, contentDescription = stringResource(R.string.event_detail_open_in_maps)) }
                } else {
                    null
                },
                modifier = Modifier.clickable(enabled = event.hasCoordinates || event.addressLines.isNotEmpty()) {
                    context.openInMaps(event)
                },
            )
        }

        if (event.isOnline) {
            ListItem(
                headlineContent = { Text(stringResource(R.string.event_online)) },
                leadingContent = { Icon(Icons.Outlined.Videocam, contentDescription = null) },
            )
        }

        FlowRow(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            if (event.startDate != null && !event.isCancelled) {
                FilledTonalButton(onClick = { context.addToCalendar(event) }) {
                    Icon(Icons.Outlined.CalendarMonth, contentDescription = null)
                    Text(stringResource(R.string.event_detail_add_to_calendar), Modifier.padding(start = 8.dp))
                }
            }
            event.url?.let { url ->
                OutlinedButton(onClick = { context.openUri(url) }) {
                    Text(stringResource(R.string.event_detail_website))
                }
            }
        }

        (event.description ?: event.teaser)?.let { description ->
            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))
            Text(
                text = stringResource(R.string.event_detail_description_headline),
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            )
            Text(
                text = description,
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(horizontal = 16.dp),
            )
        }

        event.organizerName?.let { organizer ->
            HorizontalDivider(modifier = Modifier.padding(top = 16.dp, bottom = 8.dp))
            ListItem(
                overlineContent = { Text(stringResource(R.string.event_organizer_headline)) },
                headlineContent = { Text(organizer) },
                leadingContent = { Icon(Icons.Outlined.Groups, contentDescription = null) },
            )
            FlowRow(
                modifier = Modifier.padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                event.organizerPhone?.let { phone ->
                    AssistChip(
                        onClick = { context.openUri("tel:${phone.filter { it.isDigit() || it == '+' }}") },
                        label = { Text(stringResource(R.string.event_detail_call)) },
                        leadingIcon = { Icon(Icons.Outlined.Call, contentDescription = null) },
                    )
                }
                event.organizerEmail?.let { email ->
                    AssistChip(
                        onClick = { context.openUri("mailto:$email") },
                        label = { Text(stringResource(R.string.event_detail_email)) },
                        leadingIcon = { Icon(Icons.Outlined.Email, contentDescription = null) },
                    )
                }
                event.organizerWebsite?.let { website ->
                    AssistChip(
                        onClick = { context.openUri(website) },
                        label = { Text(stringResource(R.string.event_detail_website)) },
                        leadingIcon = { Icon(Icons.AutoMirrored.Outlined.OpenInNew, contentDescription = null) },
                    )
                }
            }
        }

        Spacer(Modifier.height(24.dp))
    }
}

private fun Context.startActivitySafely(intent: Intent) {
    try {
        startActivity(intent)
    } catch (_: ActivityNotFoundException) {
        // No app can handle the intent; there is nothing better to offer.
    }
}

private fun Context.openUri(uri: String) {
    startActivitySafely(Intent(Intent.ACTION_VIEW, Uri.parse(uri)))
}

private fun Context.openInMaps(event: Event) {
    val query = listOfNotNull(event.locationName, *event.addressLines.toTypedArray()).joinToString(", ")
    val uri = if (event.latitude != null && event.longitude != null) {
        "geo:${event.latitude},${event.longitude}?q=${event.latitude},${event.longitude}(${Uri.encode(event.locationName ?: event.name)})"
    } else {
        "geo:0,0?q=${Uri.encode(query)}"
    }
    openUri(uri)
}

private fun Context.addToCalendar(event: Event) {
    val start = event.startDate ?: return
    val intent = Intent(Intent.ACTION_INSERT, CalendarContract.Events.CONTENT_URI)
        .putExtra(CalendarContract.Events.TITLE, event.name)
        .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start)
        .putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, !event.showsTime)
        .putExtra(
            CalendarContract.Events.EVENT_LOCATION,
            listOfNotNull(event.locationName, *event.addressLines.toTypedArray()).joinToString(", "),
        )
        .putExtra(CalendarContract.Events.DESCRIPTION, listOfNotNull(event.teaser, event.url).joinToString("\n\n"))
    event.endDate?.let { intent.putExtra(CalendarContract.EXTRA_EVENT_END_TIME, it) }
    startActivitySafely(intent)
}

private fun Context.shareEvent(name: String, url: String) {
    val send = Intent(Intent.ACTION_SEND)
        .setType("text/plain")
        .putExtra(Intent.EXTRA_SUBJECT, name)
        .putExtra(Intent.EXTRA_TEXT, "$name\n$url")
    startActivitySafely(Intent.createChooser(send, null))
}

@Preview(showBackground = true)
@Composable
private fun EventDetailContentPreview() {
    MeinMoersTheme {
        EventDetailContent(
            event = Event(
                id = 999,
                name = "Offene PC-Sprechstunde",
                startDate = 1_794_000_000_000L,
                endDate = 1_794_005_400_000L,
                description = "Die vhs bietet Ihnen hier die Möglichkeit, einfach mal vorbeizukommen und Ihre Fragen zu stellen.",
                category = "Information und Weiterbildung",
                url = "https://moers.de/veranstaltungen/offene-pc-sprechstunde-0",
                locationName = "Wilhelm-Schroeder-Straße 10, 47441 Moers",
                street = "Wilhelm-Schroeder-Straße 10",
                postcode = "47441",
                city = "Moers",
                latitude = 51.453199,
                longitude = 6.63157,
                organizerName = "Volkshochschule Moers - Kamp-Lintfort",
                organizerPhone = "0 28 41 / 201-565",
                organizerEmail = "Volkshochschule@Moers.de",
                organizerWebsite = "https://www.vhs-moers.de/",
            ),
        )
    }
}
