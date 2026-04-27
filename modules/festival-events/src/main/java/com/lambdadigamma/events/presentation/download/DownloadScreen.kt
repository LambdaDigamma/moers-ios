package com.lambdadigamma.events.presentation.download

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Button
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.R
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.presentation.composable.EventItem
import com.lambdadigamma.events.presentation.timetable.TimetableIntent

@Composable
fun DownloadEventsRoute(
    viewModel: DownloadEventsViewModel = hiltViewModel(),
    onBack: () -> Unit
) {

    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    DownloadEventsScreen(uiState = uiState, onIntent = viewModel::acceptIntent, onBack = onBack)

}

@Composable
fun DownloadEventsScreen(
    uiState: DownloadEventsUiState,
    onIntent: (DownloadEventsIntent) -> Unit,
    onBack: () -> Unit
) {

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(id = com.lambdadigamma.events.R.string.download_timetable))
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = stringResource(R.string.navigation_back)
                        )
                    }
                }
            )
        },
    ) { padding ->

        LazyColumn(
            modifier = Modifier
                .padding(padding),
            content = {

                item {

                    Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)) {

                        BasicText(
                            text = stringResource(com.lambdadigamma.events.R.string.download_timetable_description),
                            style = MaterialTheme.typography.bodyLarge.copy(color = MaterialTheme.colorScheme.onBackground)
                        )

                    }

                    Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)) {

                        val checkedState = remember { mutableStateOf(true) }
                        val downloadImage = remember { mutableStateOf(false) }

                        Row(modifier = Modifier
                            .padding()
                            .fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {

                            BasicText(
                                text = stringResource(com.lambdadigamma.events.R.string.download_timetable_content_option),
                                style = MaterialTheme.typography.bodyLarge.copy(
                                    color = MaterialTheme.colorScheme.onBackground
                                )
                            )

                            Switch(
                                checked = checkedState.value,
                                onCheckedChange = { checkedState.value = it }
                            )

                        }

                        HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

                        Row(modifier = Modifier
                            .padding()
                            .fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {

                            BasicText(
                                text = stringResource(com.lambdadigamma.events.R.string.download_timetable_media_option),
                                style = MaterialTheme.typography.bodyLarge.copy(
                                    color = MaterialTheme.colorScheme.onBackground
                                )
                            )

                            Switch(
                                checked = downloadImage.value,
                                onCheckedChange = { downloadImage.value = it }
                            )

                        }

                        HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

                        Button(
	                            modifier = Modifier
	                                .padding(top = 20.dp)
	                                .fillMaxWidth(),
                            enabled = checkedState.value || downloadImage.value,
	                            onClick = {
                                onIntent(
                                    DownloadEventsIntent.DownloadContent(
                                        includeContent = checkedState.value,
                                        includeMedia = downloadImage.value,
                                    )
                                )
	                            }
	                        ) {
                            Text(text = stringResource(com.lambdadigamma.events.R.string.download_timetable_cta))
                        }

                    }

                    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

                }

                items(
                    items = uiState.events,
                    key = { event -> event.id },
                ) { item ->
	                    DownloadEventRow(uiState = DownloadEventRowState(
	                        name = item.name,
	                        contentState = if (item.hasPageDownloaded) DownloadEventState.DOWNLOADED else DownloadEventState.NOT_DOWNLOADED,
                        imageState = if (item.hasMediaDownloaded) DownloadEventState.DOWNLOADED else DownloadEventState.NOT_DOWNLOADED,
	                    ))
                    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant, modifier = Modifier.padding(start = 16.dp))
                }

            }
        )

    }

}

@Preview
@Composable
private fun DownloadScreenPreview() {
    MoersFestivalTheme {
        DownloadEventsScreen(
            onBack = {},
            uiState = DownloadEventsUiState(
                isLoading = false,
                events = listOf(

                )
            ),
            onIntent = {}
        )
    }
}
