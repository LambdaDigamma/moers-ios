package com.lambdadigamma.fuel.list

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.ui.AddressUiState
import com.lambdadigamma.fuel.ui.FuelPriceText

data class FuelStationUiState(
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
)

@Composable
fun FuelStationList(
    items: List<FuelStationUiState>,
    modifier: Modifier = Modifier,
    onShowFuelStation: (String) -> Unit
) {
    LazyColumn(
        modifier = modifier
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(bottom = 32.dp),
        verticalArrangement = Arrangement.spacedBy(0.dp),
    ) {
        items(items, key = { it.id }) { item ->
            FuelStationRow(item, onClick = onShowFuelStation)
        }
        item {
            Column(modifier = Modifier.padding(16.dp)) {
                Divider(
                    color = MaterialTheme.colorScheme.tertiary.copy(alpha = 0.1f),
                    modifier = Modifier.padding(bottom = 16.dp)
                )
                Text(
                    text = "CC BY 4.0 - https://creativecommons.tankerkoenig.de",

                    color = MaterialTheme.colorScheme.secondary,
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun FuelStationRow(item: FuelStationUiState, onClick: (String) -> Unit) {

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                onClick(item.id)
            }
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        Column(
            modifier = Modifier
                .padding(end = 12.dp)
                .weight(0.5f)
        ) {
            Text(text = item.brand, fontWeight = FontWeight.Bold)
            Text(
                text = (if (item.distance != null) "${item.distance}km • " else "") + item.name.trim(),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
        Card(
            modifier = Modifier
                .clipToBounds()
                .width(IntrinsicSize.Max),
            shape = RoundedCornerShape(4.dp),
        ) {
            Column(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)) {
                FuelPriceText(
                    price = item.price,
                    fontWeight = FontWeight.Bold,
                    style = LocalTextStyle.current.copy(fontFeatureSettings = "tnum")
                )
            }
        }
    }

}

@Preview
@Composable
fun FuelStationListPreview() {
    FuelStationList(
        items = listOf(
            FuelStationUiState(
                id = "1",
                brand = "Markant",
                name = "Yadigar Güner",
                price = 1.599,
                point = Point(latitude = 52.5, longitude = 13.4)
            ),
            FuelStationUiState(
                id = "2",
                brand = "SB",
                name = "Sb Moers",
                price = 1.609,
                point = Point(latitude = 52.5, longitude = 13.4)
            ),
            FuelStationUiState(
                id = "3",
                brand = "JET",
                name = "MOERS",
                price = 1.619,
                point = Point(latitude = 52.5, longitude = 13.4)
            ),
            FuelStationUiState(
                id = "4",
                brand = "CLASSIC",
                name = "Supermarkt-Tankstelle Moers Breslauer Strasse 35 47441 Moers",
                price = 1.619,
                point = Point(latitude = 52.5, longitude = 13.4),
            ),
            FuelStationUiState(
                id = "5",
                brand = "Kuster Energy",
                name = "Kuster Energy",
                price = 1.659,
                point = Point(latitude = 52.5, longitude = 13.4),
            ),
        ),
        onShowFuelStation = {}
    )
}