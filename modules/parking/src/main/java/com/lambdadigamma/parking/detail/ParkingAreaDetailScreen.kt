package com.lambdadigamma.parking.detail

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import app.moers.core.geo.GeoJsonPoint
import app.moers.core.geo.Point
import app.moers.core.theme.MeinMoersTheme
import app.moers.core.ui.ElevatedNavigationButton
import app.moers.core.ui.NavigationBackButton
import app.moers.core.ui.RelativeDateText
import app.moers.core.ui.ResourcefulContent
import com.lambdadigamma.parking.ParkingAreaOpeningState
import com.lambdadigamma.parking.backgroundColor
import com.lambdadigamma.parking.localizedName
import com.lambdadigamma.parking.textColor
import java.util.*

data class ParkingAreaDetailState(
    val id: Int,
    val name: String,
    val location: GeoJsonPoint,
    val currentOpeningState: ParkingAreaOpeningState,
    val freeSites: Int,
    val occupiedSites: Int,
    val occupancy: List<Occupancy>,
    val capacity: Int,
    val lastUpdated: Date,
)

@Composable
fun ParkingAreaDetailScreen(id: Int, onBack: () -> Unit) {

    val viewModel: ParkingAreaDetailViewModel = hiltViewModel()
    val resource = viewModel.load(id = id)

    ResourcefulContent(resource = resource, onLoad = { /*TODO*/ }) { parkingArea ->
        ParkingAreaDetailContent(parkingArea = parkingArea, onBack = onBack)
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ParkingAreaDetailContent(parkingArea: ParkingAreaDetailState, onBack: () -> Unit) {

    Scaffold(topBar = {
        SmallTopAppBar(
            title = {
                Text(text = "Details")
            },
            navigationIcon = {
                NavigationBackButton(onBack = onBack)
            }
        )
    }) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(it),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {

            CurrentState(
                name = parkingArea.name,
                freeSites = parkingArea.freeSites,
                capacity = parkingArea.capacity,
                currentOpeningState = parkingArea.currentOpeningState,
                lastUpdate = parkingArea.lastUpdated,
                modifier = Modifier.padding(horizontal = 16.dp)
            )

            Map(
                modifier = Modifier.padding(horizontal = 16.dp),
                point = parkingArea.location.toPoint()
            )

//            PastOccupancy(
//                modifier = Modifier.padding(horizontal = 16.dp),
//                occupancy = parkingArea.occupancy
//            )

        }
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CurrentState(
    name: String,
    freeSites: Int,
    capacity: Int,
    currentOpeningState: ParkingAreaOpeningState,
    lastUpdate: Date,
    modifier: Modifier = Modifier
) {
    ElevatedCard(modifier = modifier) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column {
                    Text(
                        text = name,
                        style = MaterialTheme.typography.titleLarge,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Row(modifier = Modifier.padding(bottom = 8.dp)) {
                        Text(text = freeSites.toString(), fontWeight = FontWeight.Medium)
                        Text(
                            text = " / $capacity frei",
                            color = MaterialTheme.colorScheme.secondary,
                            style = MaterialTheme.typography.titleMedium
                        )
                    }
                }
                Text(
                    text = stringResource(id = currentOpeningState.localizedName()),
                    style = MaterialTheme.typography.bodyMedium,
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .background(currentOpeningState.backgroundColor())
                        .padding(horizontal = 12.dp, vertical = 4.dp),
                    color = currentOpeningState.textColor()
                )
            }
            LinearProgressIndicator(
                progress = 1 - (freeSites / capacity.toFloat()),
                modifier = Modifier.padding(bottom = 8.dp)
            )
            RelativeDateText(
                date = lastUpdate,
                color = MaterialTheme.colorScheme.tertiary,
                style = MaterialTheme.typography.labelMedium
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun Map(point: Point, modifier: Modifier = Modifier) {

    ElevatedNavigationButton(point = point, modifier = Modifier.padding(horizontal = 16.dp))

//    ElevatedCard(modifier = modifier) {
//        Box(
//            Modifier
//                .fillMaxWidth()
////                .background(MaterialTheme.colorScheme.surface)
//                .height(200.dp)
//                .clip(RoundedCornerShape(12.dp)),
//            contentAlignment = Alignment.Center
//        ) {
//
//
//            Text(text = "Map")
//        }
//    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun PastOccupancy(modifier: Modifier = Modifier, occupancy: List<Occupancy>) {

    ElevatedCard(modifier = modifier) {
        Column(
            modifier = Modifier
                .padding(12.dp)
                .fillMaxWidth()
        ) {
            Text(text = "Belegung in den letzten Stunden")
            ParkingAreaPastOccupancyChart(
                modifier = Modifier.padding(top = 16.dp, bottom = 8.dp),
                occupancy = occupancy
            )
        }
    }

}

@Preview
@Composable
private fun ParkingAreaDetailContentPreview() {

    val parkingArea = ParkingAreaDetailState(
        id = 1,
        name = "Neuer Wall",
        location = GeoJsonPoint(latitude = 52.5, longitude = 13.5),
        currentOpeningState = ParkingAreaOpeningState.OPEN,
        freeSites = 10,
        occupiedSites = 10,
        capacity = 20,
        lastUpdated = Date(),
        occupancy = listOf()
    )

    MeinMoersTheme {
        ParkingAreaDetailContent(parkingArea = parkingArea, onBack = {})
    }

}