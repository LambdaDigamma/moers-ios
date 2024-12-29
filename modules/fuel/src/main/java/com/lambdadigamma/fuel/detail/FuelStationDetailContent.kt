package com.lambdadigamma.fuel.detail

import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.geo.GoogleMapsNavigationProvider
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.*
import com.lambdadigamma.fuel.R
import com.lambdadigamma.fuel.ui.FuelPriceText

data class FuelStationDetailUiState(
    val id: String,
    val brand: String,
    val name: String,
    val point: Point,
    val price: Double,
    val priceDiesel: Double? = null,
    val priceE5: Double? = null,
    val priceE10: Double? = null,
    val distance: Double? = null,
    val address: AddressUiState? = null,
    val openingHours: List<OpeningHoursEntry> = listOf(),
    val isOpen: Boolean = true
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FuelStationDetailContent(fuelStation: FuelStationDetailUiState, onBack: () -> Unit) {

    Scaffold(topBar = {
        SmallTopAppBar(
            title = { Text(text = stringResource(R.string.parking_area_detail_title)) },
            navigationIcon = {
                NavigationBackButton(onBack = onBack)
            }
        )
    }) { padding ->

        Column(
            modifier = Modifier
                .padding(padding)
                .scrollable(rememberScrollState(), orientation = Orientation.Vertical),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {

//            Map(modifier = Modifier
//                .fillMaxSize()
//                .height(400.dp))

            Row(
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .padding(vertical = 8.dp)
            ) {
                Column(modifier = Modifier) {
                    Text(
                        text = fuelStation.brand,
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.SemiBold
                    )
                    Row {
                        Text(text = fuelStation.name, color = MaterialTheme.colorScheme.secondary)
                        fuelStation.distance?.let { distance ->
                            Text(
                                text = " • ${distance}km",
                                color = MaterialTheme.colorScheme.secondary
                            )
                        }
                    }
                }
                OpenBadge(isOpen = fuelStation.isOpen, cornerSize = 6.dp)
            }

            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier
                    .padding(horizontal = 16.dp)
                    .fillMaxWidth()
            ) {
                fuelStation.priceDiesel?.let { priceDiesel ->
                    PricePanel(
                        price = priceDiesel,
                        label = stringResource(R.string.fuel_label_diesel),
                        modifier = Modifier.weight(1f)
                    )
                }
                fuelStation.priceE5?.let { priceE5 ->
                    PricePanel(
                        price = priceE5,
                        label = stringResource(R.string.fuel_label_e5),
                        modifier = Modifier.weight(1f)
                    )

                }
                fuelStation.priceE10?.let { priceE10 ->
                    PricePanel(
                        price = priceE10,
                        label = stringResource(R.string.fuel_label_e10),
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            ElevatedCard(modifier = Modifier.padding(horizontal = 16.dp)) {
                OpeningHoursContainer(
                    entries = fuelStation.openingHours,
                    modifier = Modifier
                        .padding(16.dp)
                        .fillMaxWidth()
                )
            }

            ElevatedCard(
                modifier = Modifier
                    .padding(horizontal = 16.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    fuelStation.address?.let {
                        AddressContainer(
                            address = it,
                        )
                    }

                    val context = LocalContext.current

                    FilledTonalButton(
                        modifier = Modifier
                            .fillMaxWidth(),
//                            .padding(horizontal = 16.dp),
                        onClick = {
                            GoogleMapsNavigationProvider(context).startNavigation(fuelStation.point)
                        }
                    ) {
                        Text(text = stringResource(R.string.start_navigation))
                    }
                }
            }

            Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                Text(
                    text = stringResource(R.string.fuel_datasource),
                    color = MaterialTheme.colorScheme.secondary,
                    style = MaterialTheme.typography.bodySmall
                )
            }

        }
    }
}


@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun PricePanel(price: Double, label: String, modifier: Modifier = Modifier) {
    ElevatedCard(modifier = modifier) {
        Column(modifier = Modifier.padding(12.dp)) {
            Text(text = label)
            FuelPriceText(
                price = price,
                fontWeight = FontWeight.Bold,
                style = MaterialTheme.typography.headlineSmall,
            )
        }
    }
}

@Preview
@Composable
fun FuelStationDetailScreenPreview() {
    MeinMoersTheme {
        FuelStationDetailContent(
            fuelStation = FuelStationDetailUiState(
                id = "5",
                brand = "Kuster Energy",
                name = "Kuster Energy",
                point = Point(latitude = 52.5, longitude = 13.4),
                price = 1.659,
                distance = 1.2,
                priceDiesel = 1.859,
                priceE5 = 1.629,
                priceE10 = 1.679,
                address = AddressUiState(
                    street = "Musterstraße",
                    houseNumber = "1",
                    city = "Musterstadt",
                    zip = "12345",
                    state = ""
                ),
                openingHours = listOf(
                    OpeningHoursEntry(
                        label = "Mo-Fr",
                        value = "07:00 - 22:00"
                    ),
                    OpeningHoursEntry(
                        label = "Samstag",
                        value = "07:30 - 22:00"
                    ),
                    OpeningHoursEntry(
                        label = "Sonntag, Feiertag",
                        value = "08:00 - 22:00"
                    )
                )
            ),
            onBack = {}
        )
    }
}