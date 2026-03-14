package com.lambdadigamma.map.presentation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.map.R
import com.lambdadigamma.map.presentation.composable.FestivalMapView
import com.lambdadigamma.map.presentation.composable.SelectedFeatureCard

@Composable
internal fun MapScreen(
    uiState: MapUiState,
    onIntent: (MapIntent) -> Unit,
) {

    Scaffold(topBar = {
        TopBar(
            title = stringResource(R.string.map_title),
            actions = {
                IconButton(
                    enabled = !uiState.isRefreshing,
                    onClick = { onIntent(MapIntent.Refresh) },
                ) {
                    Icon(
                        imageVector = Icons.Rounded.Refresh,
                        contentDescription = stringResource(R.string.map_refresh),
                    )
                }
            },
        )
    }) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(it),
        ) {
            FestivalMapView(
                uiState = uiState,
                onIntent = onIntent,
                modifier = Modifier.fillMaxSize(),
            )

            Column(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                if (uiState.isRefreshing) {
                    LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
                }

                uiState.refreshError?.localizedMessage
                    ?.takeIf { message -> message.isNotBlank() }
                    ?.let { message ->
                        ElevatedCard(modifier = Modifier.fillMaxWidth()) {
                            Text(
                                text = stringResource(R.string.map_refresh_error, message),
                                modifier = Modifier.padding(16.dp),
                            )
                        }
                    }
            }

            uiState.selectedFeature?.let { feature ->
                SelectedFeatureCard(
                    feature = feature,
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(16.dp),
                )
            }

            if (uiState.isLoading && uiState.layers.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                )
            }
        }
    }
}
