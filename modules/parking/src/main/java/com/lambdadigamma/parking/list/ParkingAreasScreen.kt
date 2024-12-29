package com.lambdadigamma.parking.list

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.core.ui.RelativeDateText
import com.lambdadigamma.core.ui.ResourcefulContent
import com.lambdadigamma.parking.ParkingAreaOpeningState
import com.lambdadigamma.parking.R
import com.lambdadigamma.parking.localizedName
import java.util.*
import kotlin.math.max

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ParkingAreasScreen(onSelectParkingArea: (Int) -> Unit, onBack: () -> Unit) {

    val viewModel: ParkingAreaListViewModel = hiltViewModel()
    val resource = viewModel.load()

    Scaffold(
        topBar = {
            SmallTopAppBar(title = {
                Text(text = stringResource(R.string.parking_areas_title))
            }, navigationIcon = {
                NavigationBackButton(onBack = onBack)
            })
        },
        content = {
            ResourcefulContent(resource = resource, onLoad = { /*TODO*/ }) { parkingAreas ->
                ParkingAreaScreenContent(
                    parkingAreas = parkingAreas,
                    modifier = Modifier.padding(it),
                    onSelectParkingArea = onSelectParkingArea
                )
            }
        }
    )
}

@Composable
private fun ParkingAreaScreenContent(
    parkingAreas: List<ParkingAreaListItem>,
    modifier: Modifier = Modifier,
    onSelectParkingArea: (Int) -> Unit
) {
    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        modifier = modifier
    ) {

        items(parkingAreas, key = { it.id }) { parkingArea ->
            ParkingAreaDashboard(
                name = parkingArea.name,
                freeSites = max(parkingArea.capacity - parkingArea.occupiedSites, 0),
                capacity = parkingArea.capacity,
                currentOpeningState = parkingArea.currentOpeningState,
                lastUpdate = parkingArea.lastUpdated,
                onClick = { onSelectParkingArea(parkingArea.id) }
            )
        }

        item(span = { GridItemSpan(2) }) {
            Column(modifier = Modifier) {
                Text(
                    text = stringResource(R.string.parking_areas_resource_disclaimer),
                    color = MaterialTheme.colorScheme.secondary,
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.Normal
                )
                Text(
                    text = stringResource(R.string.parking_areas_resource_source),
                    color = MaterialTheme.colorScheme.secondary,
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.Normal
                )
            }
        }

    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ParkingAreaDashboard(
    name: String,
    freeSites: Int,
    capacity: Int,
    currentOpeningState: ParkingAreaOpeningState,
    lastUpdate: Date,
    onClick: () -> Unit
) {
    ElevatedCard(onClick = onClick) {
        Surface(tonalElevation = 8.dp, modifier = Modifier.fillMaxWidth()) {
            Row(
                horizontalArrangement = Arrangement.End,
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(
                    text = stringResource(id = currentOpeningState.localizedName()),
                    style = MaterialTheme.typography.labelMedium
                )
            }
        }
        Column(modifier = Modifier.padding(12.dp)) {
            Text(
                text = name,
                style = MaterialTheme.typography.titleMedium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Row(modifier = Modifier.padding(bottom = 8.dp)) {
                Text(text = freeSites.toString(), fontWeight = FontWeight.Medium)
                Text(text = " / $capacity frei", color = MaterialTheme.colorScheme.secondary)
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

@Preview(showBackground = true)
@Composable
private fun ParkingAreaScreenPreview() {
    MeinMoersTheme {
        ParkingAreaScreenContent(
            parkingAreas = listOf(
                ParkingAreaListItem(
                    id = 1,
                    name = "Kautzstr.",
                    capacity = 700,
                    occupiedSites = 38,
                    currentOpeningState = ParkingAreaOpeningState.OPEN,
                    lastUpdated = Date()
                ),
                ParkingAreaListItem(
                    id = 2,
                    name = "Bankstr.",
                    capacity = 400,
                    occupiedSites = 124,
                    currentOpeningState = ParkingAreaOpeningState.OPEN,
                    lastUpdated = Date()
                ),
                ParkingAreaListItem(
                    id = 3,
                    name = "Kastell",
                    capacity = 700,
                    occupiedSites = 142,
                    currentOpeningState = ParkingAreaOpeningState.OPEN,
                    lastUpdated = Date()
                ),
                ParkingAreaListItem(
                    id = 4,
                    name = "Mühlenstr.",
                    capacity = 700,
                    occupiedSites = 698,
                    currentOpeningState = ParkingAreaOpeningState.CLOSED,
                    lastUpdated = Date()
                ),
                ParkingAreaListItem(
                    id = 5,
                    name = "Kautzstr. (Parkplatz)",
                    capacity = 102,
                    occupiedSites = 32,
                    currentOpeningState = ParkingAreaOpeningState.UNKNOWN,
                    lastUpdated = Date()
                ),
            ),
            onSelectParkingArea = {}
//            modifier = Modifier.padding(16.dp)
        )
    }
}