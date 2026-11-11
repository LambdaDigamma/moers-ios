package com.lambdadigamma.parking.detail

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.ElevatedNavigationButton
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.parking.ParkingArea
import com.lambdadigamma.parking.R
import com.lambdadigamma.parking.isOutdated
import com.lambdadigamma.parking.localizedName
import com.lambdadigamma.parking.ui.ParkingDisclaimer
import com.lambdadigamma.parking.ui.ParkingOutdatedWarning
import com.lambdadigamma.parking.ui.relativeUpdateText
import java.util.Date

@Composable
fun ParkingAreaDetailScreen(id: Int, onBack: () -> Unit) {
    val viewModel: ParkingAreaDetailViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val title = (uiState as? ParkingAreaDetailUiState.Loaded)?.response?.parkingArea?.name
        ?: stringResource(R.string.parking_areas_title)

    Scaffold(topBar = { TopBar(title = title, onBack = onBack) }) { padding ->
        val modifier = Modifier
            .padding(padding)
            .fillMaxSize()
        when (val state = uiState) {
            ParkingAreaDetailUiState.Loading -> LoadingContent(modifier)
            ParkingAreaDetailUiState.Failed -> ErrorContent(message = null, modifier = modifier, onRetry = viewModel::load)
            is ParkingAreaDetailUiState.Loaded -> ParkingAreaDetailContent(
                parkingArea = state.response.parkingArea,
                occupancy = state.response.pastOccupancy?.data?.data.orEmpty(),
                modifier = modifier,
            )
        }
    }
}

@Composable
fun ParkingAreaDetailContent(
    parkingArea: ParkingArea,
    occupancy: List<Occupancy>,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        if (listOf(parkingArea).isOutdated()) {
            ParkingOutdatedWarning(lastUpdate = parkingArea.updatedAt)
        }

        ElevatedCard(modifier = Modifier.fillMaxWidth()) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp),
            ) {
                Text(
                    text = stringResource(parkingArea.openingState.localizedName()),
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.primary,
                )
                Text(
                    text = if (parkingArea.hasLiveData) {
                        stringResource(R.string.parking_free_of_capacity, parkingArea.freeSites, parkingArea.capacity)
                    } else {
                        stringResource(R.string.parking_no_live_data)
                    },
                    style = MaterialTheme.typography.headlineSmall,
                )
                LinearProgressIndicator(
                    progress = { parkingArea.occupancy },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp),
                )
                relativeUpdateText(parkingArea.updatedAt)?.let { text ->
                    Text(text, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }

        parkingArea.location?.let { location ->
            ElevatedNavigationButton(point = location.toPoint())
        }

        if (occupancy.isNotEmpty()) {
            ElevatedCard(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(stringResource(R.string.parking_occupancy_title), style = MaterialTheme.typography.titleMedium)
                    OccupancyChart(
                        occupancy = occupancy,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 16.dp)
                            .height(120.dp),
                    )
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Text("${occupancy.first().hour}:00", style = MaterialTheme.typography.labelSmall)
                        Text("${occupancy.last().hour}:00", style = MaterialTheme.typography.labelSmall)
                    }
                }
            }
        }

        ParkingDisclaimer()
    }
}

/** Hourly occupancy as bars from 0 to 100 %. */
@Composable
private fun OccupancyChart(occupancy: List<Occupancy>, modifier: Modifier = Modifier) {
    val barColor = MaterialTheme.colorScheme.primary
    val trackColor = MaterialTheme.colorScheme.surfaceContainerHighest
    Canvas(modifier = modifier) {
        val count = occupancy.size
        val gap = 2.dp.toPx()
        val barWidth = ((size.width - gap * (count - 1)) / count).coerceAtLeast(1f)
        occupancy.forEachIndexed { index, entry ->
            val x = index * (barWidth + gap)
            val rate = entry.occupancyRate.toFloat().coerceIn(0f, 1f)
            val radius = CornerRadius(barWidth / 3, barWidth / 3)
            drawRoundRect(trackColor, Offset(x, 0f), Size(barWidth, size.height), radius)
            val barHeight = size.height * rate
            drawRoundRect(barColor, Offset(x, size.height - barHeight), Size(barWidth, barHeight), radius)
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ParkingAreaDetailContentPreview() {
    MeinMoersTheme {
        ParkingAreaDetailContent(
            parkingArea = ParkingArea(13, "Altstadt", "altstadt", null, null, 104, 16, null, Date()),
            occupancy = (0 until 24).map { Occupancy(occupancyRate = (it % 12) / 12.0, hour = (it + 2) % 24) },
        )
    }
}
