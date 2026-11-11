package com.lambdadigamma.fuel.list

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.lambdadigamma.core.Status
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.fuel.R
import com.lambdadigamma.fuel.R.drawable
import com.lambdadigamma.fuel.data.FuelType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FuelStationListScreen(onBack: () -> Unit, onShowFuelStation: (String) -> Unit) {

    val viewModel: FuelStationListViewModel = hiltViewModel()
    val stations by viewModel.fuelStations.observeAsState()
    val fuelType by viewModel.fuelType.observeAsState()

    LaunchedEffect(key1 = "load_fuel_stations", block = {
        viewModel.reload()
    })

    Column(
        modifier = Modifier
            .fillMaxSize()
    ) {
        TopAppBar(
            title = {
                Text(stringResource(R.string.fuel_stations_title))
            },
            navigationIcon = {
                NavigationBackButton(onBack = onBack)
            },
            actions = {
                IconButton(onClick = { }) {
                    Icon(Icons.Outlined.Info, "")
                }
            }
        )
        when (stations?.status) {
            Status.SUCCESS -> {
                Column(modifier = Modifier.fillMaxSize()) {
                    FuelStationList(
                        items = stations?.data.orEmpty(),
                        modifier = Modifier.weight(1f),
                        onShowFuelStation = onShowFuelStation
                    )
                    FuelStationSearchInfo(type = fuelType ?: FuelType.DIESEL)
                }
            }
            Status.LOADING, null -> LoadingContent()
            Status.ERROR -> ErrorContent(message = null, onRetry = viewModel::reload)
        }
    }
}
