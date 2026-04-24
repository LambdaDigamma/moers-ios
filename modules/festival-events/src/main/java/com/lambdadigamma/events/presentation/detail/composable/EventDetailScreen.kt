package com.lambdadigamma.events.presentation.detail.composable

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.presentation.detail.EventDetailDisplayable
import com.lambdadigamma.events.presentation.detail.EventDetailIntent
import com.lambdadigamma.events.presentation.detail.EventDetailUiState
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import java.util.Date

@Composable
fun EventDetailScreen(
    uiState: EventDetailUiState,
    onIntent: (EventDetailIntent) -> Unit,
    onToggleLike: () -> Unit,
    onShowVenue: (Long) -> Unit,
    onBack: () -> Unit = {},
) {

    Scaffold(topBar = {
        TopAppBar(
            title = {
                Text(text = "Details")
            },
            navigationIcon = {
                IconButton(onClick = { onBack() }) {
                    Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                }
            },
            actions = {
                IconButton(onClick = {
                    onToggleLike()
//                    onIntent(EventDetailIntent.ToggleFavorite)
                }) {
                    if (uiState.event?.isFavorite == true) {
                        Icon(imageVector = Icons.Filled.Favorite, contentDescription = "Like")
                    } else {
                        Icon(
                            imageVector = Icons.Filled.FavoriteBorder,
                            contentDescription = "Unlike"
                        )
                    }
                }
            },
        )
    }) {

        Box(modifier = Modifier
            .padding(it)
            .fillMaxSize()) {

            if (uiState.event == null) {

                if (uiState.isLoading) {
                    EventDetailLoading()
                } else {
                    if (uiState.isError != null) {
                        EventDetailError(
                            throwable = uiState.isError,
                            onRefresh = { onIntent(EventDetailIntent.GetData) }
                        )
                    }
                }

            } else {
                EventDetailContent(
                    event = uiState.event,
                    onShowVenue = onShowVenue,
                )
            }

        }

    }

}

@Composable
fun EventDetailLoading() {

    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator()
    }

}

@Composable
fun EventDetailError(throwable: Throwable, onRefresh: () -> Unit) {

    Column(modifier = Modifier.fillMaxSize()) {

        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            Text(throwable.localizedMessage ?: throwable.message ?: "Unknown error")

            Button(onClick = { onRefresh() }) {
                Text("Refresh")
            }

        }

    }

}

@Preview
@Composable
fun EventDetailScreenPreview() {
    MoersFestivalTheme {
        EventDetailScreen(
            uiState = EventDetailUiState(event = EventDetailDisplayable(
                id = 1,
                title = "Editrix (US)",
                startDate = Date(1685112300000),
                endDate = Date(1685115000000),
                artists = listOf("Editrix"),
                isOpenEnd = false,
                place = PlaceDisplayable(
                    id = 1,
                    name = "Bollwerk 107",
                    point = Point(0.0, 0.0),
                    addressLine1 = "Festivalgelände",
                    addressLine2 = "47441 Moers",
                )
            )),
            onIntent = {},
            onToggleLike = {},
            onShowVenue = {},
        )
    }
}

@Preview
@Composable
private fun EventDetailScreenPreview_Loading() {
    MoersFestivalTheme {
        EventDetailScreen(
            uiState = EventDetailUiState(
                event = null,
                isLoading = true,
            ),
            onIntent = {},
            onToggleLike = {},
            onShowVenue = {},
        )
    }
}
