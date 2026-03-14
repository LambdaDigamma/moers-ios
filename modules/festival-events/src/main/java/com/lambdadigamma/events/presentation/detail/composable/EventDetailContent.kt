package com.lambdadigamma.events.presentation.detail.composable

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.detail.EventDetailDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import com.lambdadigamma.medialibrary.composable.MediaImageView
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.presentation.PageBlockRenderer
import java.util.Date

@Composable
fun EventDetailContent(event: EventDetailDisplayable) {

    Surface(
        modifier = Modifier
            .verticalScroll(rememberScrollState())
            .fillMaxSize()
    ) {

        Column(
            modifier = Modifier.fillMaxSize()

        ) {

            event.mediaCollections.getFirstMedia("header")?.let { media ->
                MediaImageView(
                    media = media,
                    alignment = Alignment.TopCenter,
                    contentScale = ContentScale.FillWidth,
                    modifier = Modifier
                        .fillMaxWidth()
                )
            }

            EventDetailMetadata(
                title = event.title,
                location = event.place?.name,
                time = event.dateRange,
                artists = event.artists,
                startDate = event.startDate,
                isOpenEnd = event.isOpenEnd,
                scheduleDisplayMode = event.scheduleDisplayMode
            )

            HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

            if (event.blocks.isNotEmpty()) {

                val firstBlock = event.blocks.firstOrNull()?.data

                if (firstBlock is TextBlock && firstBlock.isBlank()) {
                    NoFurtherInformation()
                } else {
                    PageBlockRenderer(
                        blocks = event.blocks,
//                        modifier = Modifier.padding(top = 16.dp, bottom = 16.dp)
                    )
                }

            } else {

                NoFurtherInformation()

            }

            if (event.place != null) {

                HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

                PlaceInformation(place = event.place, modifier = Modifier
                    .padding(16.dp)
                    .padding(bottom = 32.dp))
            }

        }

    }



}

@Composable
private fun NoFurtherInformation() {
    Column(modifier = Modifier.padding(16.dp)) {
        BasicText(
            text = stringResource(R.string.no_additional_information),
            style = MaterialTheme.typography.bodyLarge.copy(
                fontStyle = FontStyle.Italic,
                color = MaterialTheme.colorScheme.onBackground
            )
        )
    }
}

@Composable
fun LabelWithIcon(label: String, icon: @Composable () -> Unit) {

    Row(
        modifier = Modifier
            .fillMaxWidth(),
        verticalAlignment = Alignment.Top,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {

        icon()

        BasicText(
            text = label,
            style = MaterialTheme.typography.bodyLarge
                .copy(color = MaterialTheme.colorScheme.onBackground)
        )

    }

}

@Preview
@Composable
private fun EventDetailContentPreview() {

    MoersFestivalTheme {
        EventDetailContent(
            EventDetailDisplayable(
                id = 1,
                title = "Editrix (US)",
                startDate = Date(1685112300000),
                endDate = Date(1685115000000),
                artists = listOf("Edith Crash"),
                isOpenEnd = false,
                place = PlaceDisplayable(
                    id = 1,
                    name = "Bollwerk 107",
                    point = Point(0.0, 0.0),
                    addressLine1 = "Festivalgelände",
                    addressLine2 = "47441 Moers",
                ),
            )
        )
    }

}
