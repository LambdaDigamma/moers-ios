package com.lambdadigamma.fuel.dashboard

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Place
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.accompanist.placeholder.material.placeholder
import com.lambdadigamma.core.Status
import com.lambdadigamma.fuel.R
import com.lambdadigamma.fuel.ui.FuelPriceText

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FuelDashboardCard(modifier: Modifier = Modifier, onClick: () -> Unit) {

    val viewModel: DashboardFuelViewModel = hiltViewModel()

    val placeholderData = FuelDashboardData(
        type = "L DIESEL",
        location = "Moers",
        price = 2.109,
        numberOfStations = 12
    )

    val dashboardResource by viewModel.dashboardData.observeAsState()

    LaunchedEffect(key1 = "dashboard_fuel_load", block = {
        viewModel.load()
    })

    ElevatedCard(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth(),
    ) {
        Box(Modifier.height(IntrinsicSize.Min)) {
            Column(
                modifier = Modifier
                    .height(IntrinsicSize.Min)
                    .blur(if (dashboardResource?.status == Status.ERROR) 10.dp else 0.dp)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Place,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp),
                                tint = MaterialTheme.colorScheme.secondary
                            )
                            Text(text = stringResource(R.string.current_location))
                        }
                        Text(
                            text = dashboardResource?.data?.location ?: placeholderData.location,
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.placeholder(
                                visible = dashboardResource?.shouldBeRedacted() ?: true,
                                color = MaterialTheme.colorScheme.secondary.copy(alpha = 0.25f),
                            )
                        )
                    }
                    Column(
                        horizontalAlignment = Alignment.End,
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        val price = dashboardResource?.data?.price ?: placeholderData.price

                        FuelPriceText(
                            price = price,
                            showSmall9 = false,
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.placeholder(
                                visible = dashboardResource?.shouldBeRedacted() ?: true,
                                color = MaterialTheme.colorScheme.secondary.copy(alpha = 0.25f),
                            )
                        )

                        Text(
                            text = "PRO ${dashboardResource?.data?.type ?: placeholderData.type}".uppercase(),
//                    color = MaterialTheme.colorScheme.onBackground,
                            style = MaterialTheme.typography.bodySmall,
                        )
                    }
                }

                val numberOfStations =
                    dashboardResource?.data?.numberOfStations ?: placeholderData.numberOfStations

                Text(
                    text = "$numberOfStations Tankstellen in Deiner näheren Umgebung haben geöffnet.",
                    style = MaterialTheme.typography.bodyMedium,
                    modifier = Modifier.placeholder(
                        visible = dashboardResource?.shouldBeRedacted() ?: true,
                        color = MaterialTheme.colorScheme.secondary.copy(alpha = 0.25f),
                    )
                )
            }
            if (dashboardResource?.status == Status.ERROR) {
                Box(
                    modifier = Modifier
                        .fillMaxSize(),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(text = "Fehler beim Laden der Daten")
                }
            }
        }
    }

}

@Preview
@Composable
private fun FuelDashboardCardPreview() {
    FuelDashboardCard(onClick = {})
}