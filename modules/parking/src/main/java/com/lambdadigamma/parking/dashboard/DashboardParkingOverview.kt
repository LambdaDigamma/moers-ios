package com.lambdadigamma.parking.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import app.moers.core.Status
import app.moers.core.theme.MeinMoersTheme
import com.lambdadigamma.parking.R

data class ParkingAreaDashboardUiState(
    val id: Int,
    val name: String,
    val freeSites: Int
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardParkingOverview(modifier: Modifier = Modifier, onClick: () -> Unit) {

    val viewModel: ParkingDashboardViewModel = hiltViewModel()
    val parkingAreas by viewModel.load().observeAsState()

    ElevatedCard(onClick = onClick, modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .clip(shape = RoundedCornerShape(4.dp))
                    .background(Color.Blue)
            ) {
                Icon(
                    painter = painterResource(id = R.drawable.ic_baseline_local_parking_24),
                    contentDescription = null,
                    tint = Color.White,
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
        Divider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))

        when (parkingAreas?.status) {
            Status.SUCCESS -> {
                DashboardParkingView(parkingAreas = parkingAreas?.data.orEmpty())
            }
            Status.ERROR -> {
                parkingAreas?.errorMessage?.let {
                    DashboardParkingAreaError(it)
                }
            }
            Status.LOADING -> {
                DashboardParkingAreaLoading()
            }
            null -> {
                DashboardParkingAreaLoading()
            }
        }
    }

}

@Composable
fun DashboardParkingView(
    parkingAreas: List<ParkingAreaDashboardUiState>,
    modifier: Modifier = Modifier
) {
    val chunked = parkingAreas.chunked(2)

    Column(
        modifier = Modifier.padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        for (chunk in chunked) {
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                for (parkingArea in chunk) {
                    ParkingAreaInfo(
                        name = parkingArea.name,
                        freeSites = parkingArea.freeSites,
                        modifier = Modifier.weight(0.5f)
                    )
                    // This is needed to create two column layout
                    // even if there is only one parking area.
                    if (chunk.size == 1) {
                        Box(modifier = Modifier.weight(0.5f))
                    }
                }
            }
        }
    }
}

@Composable
private fun ParkingAreaInfo(name: String, freeSites: Int, modifier: Modifier = Modifier) {
    Row(
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
        modifier = modifier.fillMaxWidth()
    ) {
        Text(
            text = name,
            style = MaterialTheme.typography.bodyLarge,
        )
        Text(
            text = "$freeSites",
            fontFamily = FontFamily.Monospace,
            fontWeight = FontWeight.SemiBold,
            style = MaterialTheme.typography.labelLarge,
            modifier = Modifier
                .clip(RoundedCornerShape(4.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant)
                .padding(horizontal = 8.dp, vertical = 2.dp)
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun PreviewDashboardParkingOverview() {

    val parkingAreas = listOf(
        ParkingAreaDashboardUiState(
            id = 1,
            name = "Kautzstr.",
            freeSites = 38
        ),
        ParkingAreaDashboardUiState(
            id = 2,
            name = "Bankstr.",
            freeSites = 124
        ),
        ParkingAreaDashboardUiState(
            id = 3,
            name = "Kastell",
            freeSites = 142
        ),
        ParkingAreaDashboardUiState(
            id = 4,
            name = "Mühlenstr.",
            freeSites = 698
        ),
    )

    MeinMoersTheme {
        DashboardParkingView(parkingAreas, modifier = Modifier.padding(16.dp))
    }
}