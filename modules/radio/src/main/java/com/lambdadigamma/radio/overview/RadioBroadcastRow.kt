package com.lambdadigamma.radio.overview

import android.text.format.DateUtils
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.lambdadigamma.core.theme.MeinMoersTheme
import java.util.*

data class RadioBroadcastListUiState(
    val id: Int,
    val title: String,
    val startsAt: Date? = null,
    val endsAt: Date? = null,
    val imageUrl: String? = null,
)

@Composable
fun RadioBroadcastRow(
    modifier: Modifier = Modifier,
    radioBroadcast: RadioBroadcastListUiState
) {

    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {

        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(4.dp))
                .size(50.dp, 50.dp)
                .background(MaterialTheme.colorScheme.surfaceVariant)

        ) {
            radioBroadcast.imageUrl?.let { imageUrl ->
                AsyncImage(
                    model = imageUrl,
                    contentDescription = null,
                    alignment = Alignment.TopCenter,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxWidth()
                )
            }
        }

        Column {
            Text(
                text = radioBroadcast.title,
                fontWeight = FontWeight.Medium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            val context = LocalContext.current

            radioBroadcast.startsAt?.let { startsAt ->
                radioBroadcast.endsAt?.let { endsAt ->
                    val formatted = remember {
                        DateUtils.formatDateRange(
                            context,
                            startsAt.time,
                            endsAt.time,
                            DateUtils.FORMAT_SHOW_DATE
                                    or DateUtils.FORMAT_SHOW_TIME
                                    or DateUtils.FORMAT_ABBREV_MONTH
                                    or DateUtils.FORMAT_ABBREV_RELATIVE
                                    or DateUtils.FORMAT_SHOW_WEEKDAY
                                    or DateUtils.FORMAT_ABBREV_WEEKDAY
                        )
                    }

                    Text(
                        text = formatted,
                    )

                }

            }

        }

    }

}

@Preview
@Composable
fun RadioBroadcastRowPreview() {
    MeinMoersTheme {
        RadioBroadcastRow(
            radioBroadcast = RadioBroadcastListUiState(
                id = 1,
                title = "Sicherheit auf dem Rhein: eine Simulation mit der Feuerwehr Wesel",
                startsAt = Date(),
                endsAt = Date(),
            )
        )
    }
}