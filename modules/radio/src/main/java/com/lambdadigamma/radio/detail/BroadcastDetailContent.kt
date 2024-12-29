package com.lambdadigamma.radio.detail

import android.text.format.DateUtils
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.NavigationBackButton
import java.util.*

data class BroadcastDetailUiState(
    val title: String,
    val description: String?,
    val startsAt: Date? = null,
    val endsAt: Date? = null,
    val imageUrl: String? = null
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BroadcastDetailContent(broadcast: BroadcastDetailUiState, onBack: () -> Unit) {

    val context = LocalContext.current

    Scaffold(topBar = {
        SmallTopAppBar(title = {
            Text(text = "Details")
        }, navigationIcon = {
            NavigationBackButton(onBack = onBack)
        })
    }) { paddingValues ->

        Column(
            modifier = Modifier
                .padding(paddingValues)
                .background(MaterialTheme.colorScheme.background)
                .padding(16.dp)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
        ) {

            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {

                broadcast.imageUrl?.let { imageUrl ->
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .size(200.dp, 200.dp)
                            .background(MaterialTheme.colorScheme.surfaceVariant)

                    ) {
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

                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {

                    Text(
                        text = broadcast.title,
                        style = MaterialTheme.typography.headlineSmall
                    )

                    broadcast.startsAt?.let { startsAt ->
                        broadcast.endsAt?.let { endsAt ->
                            val formatted = remember {
                                DateUtils.formatDateRange(
                                    context,
                                    startsAt.time,
                                    endsAt.time,
                                    DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_SHOW_TIME or DateUtils.FORMAT_ABBREV_MONTH or DateUtils.FORMAT_ABBREV_RELATIVE
                                )
                            }

                            Text(
                                text = formatted,
                            )
                        }

                    }

                    broadcast.description?.let { description ->
                        Text(
                            text = description,
                            modifier = Modifier.padding(top = 12.dp)
                        )
                    }

                }

            }

        }
    }

}

@Preview
@Composable
private fun PreviewBroadcastDetailContent() {

    val broadcast = BroadcastDetailUiState(
        title = "Was ist los im Kreis Wesel",
        description = "Antworten auf diese Frage gibt's im Magazin aus Neukirchen-Vluyn und dazu viel Oldie-Musik.",
        startsAt = Date(),
        endsAt = Date(),
        imageUrl = "https://picsum.photos/200/200"
    )

    MeinMoersTheme {
        BroadcastDetailContent(broadcast = broadcast, onBack = {})
    }
}