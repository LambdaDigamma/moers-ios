package com.lambdadigamma.moers.dashboard

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.ui.LargeTopBar
import com.lambdadigamma.fuel.dashboard.FuelDashboardCard
import com.lambdadigamma.moers.R
import com.lambdadigamma.parking.dashboard.DashboardParkingOverview
import com.lambdadigamma.rubbish.dashboard.DashboardRubbishComponent

enum class DashboardAction {
    Fuel, Rubbish, ChooseStreet, Parking, About, Feedback
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(onAction: (DashboardAction) -> Unit, onOpenSettings: () -> Unit) {

    val viewModel: DashboardViewModel = hiltViewModel()
    val isCitizen by viewModel.isCitizen.collectAsStateWithLifecycle(initialValue = false)
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeTopBar(
                title = stringResource(id = R.string.navigation_dashboard),
                scrollBehavior = scrollBehavior,
                actions = {
                    DashboardMenu(onOpenSettings = onOpenSettings, onAction = onAction)
                },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            FuelDashboardCard { onAction(DashboardAction.Fuel) }
            if (isCitizen) {
                DashboardRubbishComponent(
                    onChooseStreet = { onAction(DashboardAction.ChooseStreet) },
                    onClick = { onAction(DashboardAction.Rubbish) },
                )
            }
            DashboardParkingOverview { onAction(DashboardAction.Parking) }
        }
    }
}

@Composable
private fun DashboardMenu(onOpenSettings: () -> Unit, onAction: (DashboardAction) -> Unit) {
    var expanded by remember { mutableStateOf(false) }
    Box {
        IconButton(onClick = { expanded = true }) {
            Icon(Icons.Filled.MoreVert, contentDescription = stringResource(R.string.dashboard_more_options))
        }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            DropdownMenuItem(
                text = { Text(text = stringResource(id = R.string.settings)) },
                onClick = {
                    expanded = false
                    onOpenSettings()
                },
            )
            DropdownMenuItem(
                text = { Text(text = stringResource(R.string.feedback_navigation)) },
                onClick = {
                    expanded = false
                    onAction(DashboardAction.Feedback)
                },
            )
            DropdownMenuItem(
                text = { Text(text = stringResource(R.string.about_navigation)) },
                onClick = {
                    expanded = false
                    onAction(DashboardAction.About)
                },
            )
        }
    }
}
