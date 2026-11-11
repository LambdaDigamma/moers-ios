package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.material3.Button
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.fuel.data.FuelRepository
import com.lambdadigamma.fuel.data.FuelType
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost

@Composable
fun OnboardingFuelScreen(
    onContinue: () -> Unit
) {
    val viewModel: OnboardingFuelViewModel = hiltViewModel()
    val selectedFuelType by viewModel.fuelType.collectAsState(initial = FuelRepository.defaultFuelType)

    LaunchedEffect(Unit) {
        viewModel.updateFuelType(FuelRepository.defaultFuelType)
    }

    OnboardingFuelContent(
        selectedFuelType = selectedFuelType,
        onUpdateFuelType = viewModel::updateFuelType,
        onContinue = onContinue
    )
}

@Composable
fun OnboardingFuelContent(
    selectedFuelType: FuelType,
    onUpdateFuelType: (FuelType) -> Unit,
    onContinue: () -> Unit
) {
    OnboardingHost(
        content = {
            Column(
                modifier = Modifier
                    .padding(16.dp)
                    .fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text(
                    text = stringResource(R.string.onboarding_fuel_title),
                    style = MaterialTheme.typography.titleLarge
                )
                Text(
                    text = stringResource(R.string.onboarding_fuel_body),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Column(Modifier.selectableGroup()) {
                FuelType.entries.forEach { fuelType ->
                    ListItem(
                        headlineContent = { Text(fuelType.localizedName()) },
                        leadingContent = {
                            RadioButton(selected = selectedFuelType == fuelType, onClick = null)
                        },
                        modifier = Modifier.selectable(
                            selected = selectedFuelType == fuelType,
                            role = Role.RadioButton,
                            onClick = { onUpdateFuelType(fuelType) },
                        ),
                    )
                }
            }
        }
    ) {
        Button(onClick = onContinue, modifier = Modifier.fillMaxWidth()) {
            Text(text = stringResource(R.string.onboarding_location_continue))
        }
    }
}

@Preview
@Composable
private fun OnboardingFuelPreview() {
    MeinMoersTheme {
        var fuelType by remember { mutableStateOf(FuelType.DIESEL) }
        OnboardingFuelContent(
            selectedFuelType = fuelType,
            onUpdateFuelType = { fuelType = it },
            onContinue = {}
        )
    }
}
