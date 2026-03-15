package com.lambdadigamma.events.presentation.download

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicText
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.events.R

@Composable
fun DownloadStateInline(text: String, downloadEventState: DownloadEventState) {

    Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
        BasicText(
            text = text,
            style = MaterialTheme.typography.bodyLarge.copy(
                color = MaterialTheme.colorScheme.onBackground
            )
        )

        when (downloadEventState) {
            DownloadEventState.DOWNLOADING -> {
                CircularProgressIndicator()
            }
            DownloadEventState.DOWNLOADED -> {
                Icon(
                    painter = painterResource(id = R.drawable.outline_check_24),
                    contentDescription = "Heruntergeladen",
                    modifier = Modifier.size(20.dp),
                    tint = Color.Green
                )
            }
            DownloadEventState.NOT_DOWNLOADED -> {
                Icon(
                    painter = painterResource(id = R.drawable.outline_close_24),
                    contentDescription = "Nicht heruntergeladen",
                    modifier = Modifier.size(20.dp),
                    tint = Color.Red
                )
            }
        }
    }

}

@Preview(showBackground = true)
@Composable
private fun DownloadStateInlinePreview_Loading() {
    DownloadStateInline(text = "Inhalt", downloadEventState = DownloadEventState.DOWNLOADING)
}

@Preview(showBackground = true)
@Composable
private fun DownloadStateInlinePreview_Downloaded() {
    DownloadStateInline(text = "Inhalt", downloadEventState = DownloadEventState.DOWNLOADED)
}