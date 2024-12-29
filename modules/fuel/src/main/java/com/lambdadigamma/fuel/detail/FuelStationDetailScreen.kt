package com.lambdadigamma.fuel.detail

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.ui.ResourcefulContent
import com.lambdadigamma.fuel.list.FuelStationDetailViewModel

@Composable
fun FuelStationDetailScreen(id: String, onBack: () -> Unit) {

    val viewModel = hiltViewModel<FuelStationDetailViewModel>()
    viewModel.id = id

    val data = viewModel.fuelStation

    LaunchedEffect(key1 = "load_fuel_station_$id", block = {
        viewModel.load()
    })

    ResourcefulContent(resource = data, onLoad = { viewModel.load() }) {
        FuelStationDetailContent(
            fuelStation = it,
            onBack = onBack
        )
    }
}
