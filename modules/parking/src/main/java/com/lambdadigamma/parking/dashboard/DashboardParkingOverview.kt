package com.lambdadigamma.parking.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.placeholder
import com.lambdadigamma.parking.ParkingArea
import com.lambdadigamma.parking.ParkingUiState
import com.lambdadigamma.parking.ParkingViewModel
import com.lambdadigamma.parking.R
import com.lambdadigamma.parking.lastUpdate
import com.lambdadigamma.parking.ui.ParkingOutdatedWarning
import java.util.Date

@Composable
fun DashboardParkingOverview(modifier: Modifier = Modifier, onClick: () -> Unit) {
    val viewModel: ParkingViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    DashboardParkingCard(uiState = uiState, onClick = onClick, modifier = modifier)
}

@Composable
fun DashboardParkingCard(uiState: ParkingUiState, onClick: () -> Unit, modifier: Modifier = Modifier) {
    ElevatedCard(onClick = onClick, modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .clip(shape = RoundedCornerShape(4.dp))
                    .background(MaterialTheme.colorScheme.primaryContainer)
            ) {
                Icon(
                    painter = painterResource(id = R.drawable.ic_baseline_local_parking_24),
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier
                        .size(20.dp)
                        .padding(2.dp)
                )
            }
            Text(
                text = stringResource(R.string.dashboard_parking_headline),
                style = MaterialTheme.typography.titleMedium
            )
        }
        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

        val areas = uiState.parkingAreas.filter { it.hasLiveData }
        Column(
            modifier = Modifier.padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            when {
                uiState.isLoading -> repeat(3) {
                    Text("", Modifier.fillMaxWidth().placeholder(visible = true))
                }
                areas.isEmpty() -> Text(
                    text = stringResource(R.string.parking_no_live_data),
                    style = MaterialTheme.typography.bodyMedium,
                )
                else -> areas.chunked(2).forEach { row ->
                    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        row.forEach { area -> ParkingAreaInfo(area, Modifier.weight(1f)) }
                        if (row.size == 1) Box(Modifier.weight(1f))
                    }
                }
            }
        }
        if (!uiState.isLoading && uiState.isOutdated) {
            ParkingOutdatedWarning(lastUpdate = uiState.parkingAreas.lastUpdate())
        }
    }
}

@Composable
private fun ParkingAreaInfo(area: ParkingArea, modifier: Modifier = Modifier) {
    Row(
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
        modifier = modifier,
    ) {
        Text(
            text = area.name,
            style = MaterialTheme.typography.bodyLarge,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f, fill = false),
        )
        Text(
            text = "${area.freeSites}",
            fontFamily = FontFamily.Monospace,
            style = MaterialTheme.typography.labelLarge,
            modifier = Modifier
                .padding(start = 8.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(MaterialTheme.colorScheme.surfaceContainerHighest)
                .padding(horizontal = 8.dp, vertical = 2.dp)
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun DashboardParkingCardPreview() {
    fun area(id: Int, name: String, capacity: Int, occupied: Int) =
        ParkingArea(id, name, name, null, null, capacity, occupied, null, Date(System.currentTimeMillis() - 30 * 24 * 3600 * 1000L))
    MeinMoersTheme {
        DashboardParkingCard(
            uiState = ParkingUiState(
                parkingAreas = listOf(
                    area(1, "Altstadt", 104, 16),
                    area(2, "Bankstr.", 140, 1),
                    area(3, "Kastell", 110, 22),
                    area(4, "Mühlenstr.", 999, 108),
                    area(5, "C&A", 0, 0),
                ),
                isLoading = false,
            ),
            onClick = {},
            modifier = Modifier.padding(16.dp),
        )
    }
}
