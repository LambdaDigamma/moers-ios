package com.lambdadigamma.moers.dashboard

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.fuel.dashboard.FuelDashboardCard
import com.lambdadigamma.moers.R
import com.lambdadigamma.parking.dashboard.DashboardParkingOverview
import com.lambdadigamma.rubbish.dashboard.DashboardRubbishComponent

enum class DashboardAction {
    Fuel, Rubbish, Parking, About, Feedback
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(onAction: (DashboardAction) -> Unit, onOpenSettings: () -> Unit) {

    val viewModel: DashboardViewModel = hiltViewModel()
    var showMenu by remember { mutableStateOf(false) }
    val isCitizen by viewModel.isCitizen.collectAsState(initial = false)

    Scaffold(
        topBar = {
            TopBar(
                title = stringResource(id = R.string.navigation_dashboard),
                actions = {
                    IconButton(onClick = { showMenu = !showMenu }) {
                        Icon(Icons.Default.MoreVert, "")
                    }
                    DropdownMenu(
                        expanded = showMenu,
                        onDismissRequest = { showMenu = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text(text = stringResource(id = R.string.settings)) },
                            onClick = {
                                onOpenSettings()
                            }
                        )
                        DropdownMenuItem(
                            text = { Text(text = stringResource(R.string.feedback_navigation)) },
                            onClick = {
                                onAction(DashboardAction.Feedback)
                            }
                        )
                        DropdownMenuItem(
                            text = { Text(text = stringResource(R.string.about_navigation)) },
                            onClick = {
                                onAction(DashboardAction.About)
                            }
                        )
                    }
                }
            )
        },
        content = { paddingValues ->
            Column(
                modifier = Modifier
                    .padding(paddingValues)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                FuelDashboardCard {
                    onAction(DashboardAction.Fuel)
                }
                if (isCitizen) {
                    DashboardRubbishComponent {
                        onAction(DashboardAction.Rubbish)
                    }
                }
                DashboardParkingOverview {
                    onAction(DashboardAction.Parking)
                }
            }
        }
    )

}