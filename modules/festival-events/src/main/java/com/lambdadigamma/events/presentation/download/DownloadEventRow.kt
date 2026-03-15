package com.lambdadigamma.events.presentation.download

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.lambdadigamma.events.R

enum class DownloadEventState {
    DOWNLOADING,
    DOWNLOADED,
    NOT_DOWNLOADED
}

data class DownloadEventRowState(
    val name: String,
    val contentState: DownloadEventState = DownloadEventState.DOWNLOADED,
    val imageState: DownloadEventState = DownloadEventState.NOT_DOWNLOADED,
)

@Composable
fun DownloadEventRow(
    uiState: DownloadEventRowState,
    modifier: Modifier = Modifier
) {

    Column(modifier = modifier.padding(horizontal = 16.dp, vertical = 12.dp)) {

        BasicText(
            text = uiState.name,
            style = MaterialTheme.typography.bodyLarge
                .copy(
                    color = MaterialTheme.colorScheme.onBackground,
                    fontWeight = FontWeight.Medium
                ),
            maxLines = 1
        )

        Row(
            modifier = Modifier
                .padding(top = 8.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {

            DownloadStateInline(
                text = stringResource(R.string.content),
                downloadEventState = uiState.contentState
            )

//            DownloadStateInline(
//                text = "Bilder",
//                downloadEventState = uiState.imageState
//            )

        }

    }

}