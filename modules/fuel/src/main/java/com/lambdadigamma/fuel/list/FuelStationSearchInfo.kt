package com.lambdadigamma.fuel.list

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.fuel.data.FuelType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FuelStationSearchInfo(type: FuelType, modifier: Modifier = Modifier) {

    Card(
        shape = RectangleShape,
        modifier = modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {

            Column() {
                Row {
                    Text(text = "Spritsorte: ", fontWeight = FontWeight.Medium)
                    Text(text = type.localizedName())
                }
                Row {
                    Text(text = "Umgebung: ", fontWeight = FontWeight.Medium)
                    Text(text = "Aktueller Standort")
                }
            }
            Icon(imageVector = Icons.Default.Search, contentDescription = null)
        }
    }

}

@Preview
@Composable
fun FuelStationSearchInfoPreview() {
    MeinMoersTheme {
        FuelStationSearchInfo(type = FuelType.DIESEL)
    }
}