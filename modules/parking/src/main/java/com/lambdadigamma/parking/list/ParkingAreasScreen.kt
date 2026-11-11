package com.lambdadigamma.parking.list

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.parking.ParkingArea
import com.lambdadigamma.parking.ParkingUiState
import com.lambdadigamma.parking.ParkingViewModel
import com.lambdadigamma.parking.R
import com.lambdadigamma.parking.lastUpdate
import com.lambdadigamma.parking.localizedName
import com.lambdadigamma.parking.ui.ParkingDisclaimer
import com.lambdadigamma.parking.ui.ParkingOutdatedWarning
import com.lambdadigamma.parking.ui.relativeUpdateText
import java.util.Date

@Composable
fun ParkingAreasScreen(onSelectParkingArea: (Int) -> Unit, onBack: () -> Unit) {
    val viewModel: ParkingViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = { TopBar(title = stringResource(R.string.parking_areas_title), onBack = onBack) },
    ) { padding ->
        PullToRefreshBox(
            isRefreshing = uiState.isRefreshing && !uiState.isLoading,
            onRefresh = viewModel::refresh,
            modifier = Modifier
                .padding(padding)
                .fillMaxSize(),
        ) {
            when {
                uiState.isLoading -> LoadingContent()
                uiState.parkingAreas.isEmpty() -> ErrorContent(message = null, onRetry = viewModel::refresh)
                else -> ParkingAreaGrid(uiState = uiState, onSelectParkingArea = onSelectParkingArea)
            }
        }
    }
}

@Composable
private fun ParkingAreaGrid(uiState: ParkingUiState, onSelectParkingArea: (Int) -> Unit) {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 160.dp),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        modifier = Modifier.fillMaxSize(),
    ) {
        if (uiState.isOutdated) {
            item(span = { GridItemSpan(maxLineSpan) }) {
                ParkingOutdatedWarning(
                    lastUpdate = uiState.parkingAreas.lastUpdate(),
                    modifier = Modifier.padding(bottom = 4.dp),
                )
            }
        }
        items(uiState.parkingAreas, key = { it.id }) { area ->
            ParkingAreaCard(area = area, onClick = { onSelectParkingArea(area.id) })
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            ParkingDisclaimer(Modifier.padding(top = 8.dp))
        }
    }
}

@Composable
private fun ParkingAreaCard(area: ParkingArea, onClick: () -> Unit) {
    ElevatedCard(onClick = onClick) {
        Column(
            modifier = Modifier.padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            Text(
                text = stringResource(area.openingState.localizedName()),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.primary,
            )
            Text(
                text = area.name,
                style = MaterialTheme.typography.titleMedium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = if (area.hasLiveData) {
                    stringResource(R.string.parking_free_of_capacity, area.freeSites, area.capacity)
                } else {
                    stringResource(R.string.parking_no_live_data)
                },
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            LinearProgressIndicator(
                progress = { area.occupancy },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
            )
            relativeUpdateText(area.updatedAt)?.let { text ->
                Text(
                    text = text,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ParkingAreaGridPreview() {
    fun area(id: Int, name: String, capacity: Int, occupied: Int) =
        ParkingArea(id, name, name, null, null, capacity, occupied, null, Date())
    MeinMoersTheme {
        ParkingAreaGrid(
            uiState = ParkingUiState(
                parkingAreas = listOf(area(1, "Altstadt", 104, 16), area(2, "Kautzstr.", 0, 0), area(3, "Kastell", 110, 92)),
                isLoading = false,
            ),
            onSelectParkingArea = {},
        )
    }
}
